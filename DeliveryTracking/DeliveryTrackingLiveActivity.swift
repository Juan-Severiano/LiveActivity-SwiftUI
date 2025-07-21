//
//  DeliveryTrackingLiveActivity.swift
//  DeliveryTracking
//
//  Created by Francisco Juan on 18/07/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

enum DeliveryStatus: String, Codable, CaseIterable {
    case preparing = "preparing"
    case pickingUp = "picking_up"
    case onTheWay = "on_the_way"
    case delivered = "delivered"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .preparing: return "Preparando"
        case .pickingUp: return "Coletando"
        case .onTheWay: return "A caminho"
        case .delivered: return "Entregue"
        case .cancelled: return "Cancelado"
        }
    }
    
    var icon: String {
        switch self {
        case .preparing: return "🍳"
        case .pickingUp: return "🚗"
        case .onTheWay: return "🚚"
        case .delivered: return "✅"
        case .cancelled: return "❌"
        }
    }
    
    var progressPercentage: Double {
        switch self {
        case .preparing: return 0.25
        case .pickingUp: return 0.5
        case .onTheWay: return 0.75
        case .delivered: return 1.0
        case .cancelled: return 0.0
        }
    }
}

struct DeliveryTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: DeliveryStatus
        var driverName: String
        var driverPhoto: String?
        var estimatedTime: String
        var currentLocation: String
        var orderNumber: String
        var restaurantName: String
        var lastUpdate: Date
        
        init(status: DeliveryStatus = .preparing,
             driverName: String = "",
             driverPhoto: String? = nil,
             estimatedTime: String = "Calculando...",
             currentLocation: String = "",
             orderNumber: String = "",
             restaurantName: String = "",
             lastUpdate: Date = Date()) {
            self.status = status
            self.driverName = driverName
            self.driverPhoto = driverPhoto
            self.estimatedTime = estimatedTime
            self.currentLocation = currentLocation
            self.orderNumber = orderNumber
            self.restaurantName = restaurantName
            self.lastUpdate = lastUpdate
        }
    }
    
    let orderId: String
    let customerName: String
}

struct DeliveryTrackingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryTrackingAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(context.state.status.icon)
                                .font(.title2)
                            Text(context.state.status.displayName)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        
                        if !context.state.driverName.isEmpty {
                            Text(context.state.driverName)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(context.state.estimatedTime)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("ETA")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        ProgressView(value: context.state.status.progressPercentage)
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            .scaleEffect(y: 0.8)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("#\(context.state.orderNumber)")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                
                                if !context.state.currentLocation.isEmpty {
                                    Text(context.state.currentLocation)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Text(context.state.status.icon)
                        .font(.caption)
                    
                    if context.state.status == .onTheWay {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            } compactTrailing: {
                Text(context.state.estimatedTime)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .lineLimit(1)
            } minimal: {
                Text(context.state.status.icon)
                    .font(.caption)
            }
            .widgetURL(URL(string: "deliveryapp://order/\(context.attributes.orderId)"))
            .keylineTint(.green)
        }
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<DeliveryTrackingAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pedido #\(context.state.orderNumber)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(context.state.restaurantName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(context.state.estimatedTime)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Tempo estimado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 8) {
                        Text(context.state.status.icon)
                            .font(.title2)
                        
                        Text(context.state.status.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    if context.state.status == .onTheWay && !context.state.currentLocation.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            
                            Text(context.state.currentLocation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(progressColor)
                            .frame(width: geometry.size.width * context.state.status.progressPercentage, height: 4)
                            .cornerRadius(2)
                            .animation(.easeInOut(duration: 0.5), value: context.state.status.progressPercentage)
                    }
                }
                .frame(height: 4)
            }
            
            if !context.state.driverName.isEmpty && (context.state.status == .pickingUp || context.state.status == .onTheWay) {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: context.state.driverPhoto ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.driverName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("Seu entregador")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .activityBackgroundTint(.black.opacity(0.1))
        .activitySystemActionForegroundColor(.primary)
    }
    
    private var progressColor: Color {
        switch context.state.status {
        case .preparing, .pickingUp:
            return .orange
        case .onTheWay:
            return .blue
        case .delivered:
            return .green
        case .cancelled:
            return .red
        }
    }
}

// MARK: - Mock Data Manager (sem Firebase)
@MainActor
class DeliveryTrackingManager: ObservableObject {
    private var activityId: String?
    private var simulationTimer: Timer?
    private var currentStep = 0
    
    private let mockDeliverySteps: [DeliveryTrackingAttributes.ContentState] = [
        DeliveryTrackingAttributes.ContentState(
            status: .preparing,
            estimatedTime: "25-30 min",
            orderNumber: "12345",
            restaurantName: "Pizza Express",
            lastUpdate: Date()
        ),
        DeliveryTrackingAttributes.ContentState(
            status: .pickingUp,
            driverName: "Carlos Silva",
            estimatedTime: "20-25 min",
            currentLocation: "Restaurante Pizza Express",
            orderNumber: "12345",
            restaurantName: "Pizza Express",
            lastUpdate: Date()
        ),
        DeliveryTrackingAttributes.ContentState(
            status: .onTheWay,
            driverName: "Carlos Silva",
            estimatedTime: "12 min",
            currentLocation: "Rua das Flores, 123",
            orderNumber: "12345",
            restaurantName: "Pizza Express",
            lastUpdate: Date()
        ),
        DeliveryTrackingAttributes.ContentState(
            status: .onTheWay,
            driverName: "Carlos Silva",
            estimatedTime: "5 min",
            currentLocation: "Próximo ao destino",
            orderNumber: "12345",
            restaurantName: "Pizza Express",
            lastUpdate: Date()
        ),
        DeliveryTrackingAttributes.ContentState(
            status: .delivered,
            driverName: "Carlos Silva",
            estimatedTime: "Entregue",
            currentLocation: "Entregue",
            orderNumber: "12345",
            restaurantName: "Pizza Express",
            lastUpdate: Date()
        )
    ]
    
    init() {}
    
    func startTracking(orderId: String, customerName: String) {
        stopTracking()
        
        let attributes = DeliveryTrackingAttributes(
            orderId: orderId,
            customerName: customerName
        )
        
        let initialState = mockDeliverySteps[0]
        
        do {
            let activity = try Activity<DeliveryTrackingAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil)
            )
            
            self.activityId = activity.id
            currentStep = 0
            
            startSimulation()
            
        } catch {
            print("Erro ao iniciar Live Activity: \(error)")
        }
    }
    
    private func startSimulation() {
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.simulateNextStep()
            }
        }
    }
    
    private func simulateNextStep() {
        guard let activityId = activityId,
              currentStep < mockDeliverySteps.count - 1 else { return }
        
        currentStep += 1
        let nextState = mockDeliverySteps[currentStep]
        
        Task {
            let content = ActivityContent(state: nextState, staleDate: nil)
            
            for activity in Activity<DeliveryTrackingAttributes>.activities {
                if activity.id == activityId {
                    await activity.update(content)
                    break
                }
            }
            
            if nextState.status == .delivered {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    Task { @MainActor in
                        self.stopTracking()
                    }
                }
            }
        }
    }
    
    func updateToNextStep() {
        simulateNextStep()
    }
    
    func updateToStatus(_ status: DeliveryStatus) {
        guard let activityId = activityId else { return }
        
        let targetState = mockDeliverySteps.first { $0.status == status } ?? mockDeliverySteps[0]
        
        Task {
            let content = ActivityContent(state: targetState, staleDate: nil)
            
            for activity in Activity<DeliveryTrackingAttributes>.activities {
                if activity.id == activityId {
                    await activity.update(content)
                    break
                }
            }
        }
    }
    
    func stopTracking() {
        simulationTimer?.invalidate()
        simulationTimer = nil
        
        if let activityId = activityId {
            Task {
                for activity in Activity<DeliveryTrackingAttributes>.activities {
                    if activity.id == activityId {
                        await activity.end(nil, dismissalPolicy: .immediate)
                        break
                    }
                }
            }
        }
        
        activityId = nil
        currentStep = 0
    }
    
    // MARK: - Funções de Teste
    func startTestDelivery() {
        startTracking(orderId: "TEST123", customerName: "Usuário Teste")
    }
    
    var isTracking: Bool {
        return activityId != nil
    }
}

// MARK: - View para Testes (opcional - para usar no app principal)
struct DeliveryTestView: View {
    @StateObject private var manager = DeliveryTrackingManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Teste do Live Activity")
                .font(.title)
                .padding()
            
            if manager.isTracking {
                Text("Live Activity ativo!")
                    .foregroundColor(.green)
                    .font(.headline)
                
                Button("Próximo Step") {
                    manager.updateToNextStep()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Parar Rastreamento") {
                    manager.stopTracking()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
                
            } else {
                Button("Iniciar Teste") {
                    manager.startTestDelivery()
                }
                .buttonStyle(.borderedProminent)
            }
            
            VStack {
                Text("Status de Teste:")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    ForEach(DeliveryStatus.allCases, id: \.self) { status in
                        Button("\(status.icon) \(status.displayName)") {
                            manager.updateToStatus(status)
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview Extensions
extension DeliveryTrackingAttributes {
    fileprivate static var preview: DeliveryTrackingAttributes {
        DeliveryTrackingAttributes(orderId: "12345", customerName: "João Silva")
    }
}

extension DeliveryTrackingAttributes.ContentState {
    fileprivate static var preparing: DeliveryTrackingAttributes.ContentState {
        DeliveryTrackingAttributes.ContentState(
            status: .preparing,
            estimatedTime: "25-30 min",
            orderNumber: "12345",
            restaurantName: "Pizza Express"
        )
    }
    
    fileprivate static var onTheWay: DeliveryTrackingAttributes.ContentState {
        DeliveryTrackingAttributes.ContentState(
            status: .onTheWay,
            driverName: "Carlos Silva",
            estimatedTime: "8 min",
            currentLocation: "Rua das Flores, 123",
            orderNumber: "12345",
            restaurantName: "Pizza Express"
        )
    }
    
    fileprivate static var delivered: DeliveryTrackingAttributes.ContentState {
        DeliveryTrackingAttributes.ContentState(
            status: .delivered,
            driverName: "Carlos Silva",
            estimatedTime: "Entregue",
            orderNumber: "12345",
            restaurantName: "Pizza Express"
        )
    }
}

#Preview("Notification", as: .content, using: DeliveryTrackingAttributes.preview) {
    DeliveryTrackingLiveActivity()
} contentStates: {
    DeliveryTrackingAttributes.ContentState.preparing
    DeliveryTrackingAttributes.ContentState.onTheWay
    DeliveryTrackingAttributes.ContentState.delivered
}
