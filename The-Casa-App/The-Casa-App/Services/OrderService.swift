import Foundation

class OrderService {
    static let shared = OrderService()
    private let client = APIClient.shared
    
    private init() {}
    
    func fetchShippingMethods(completion: @escaping (Result<[ShippingMethod], APIError>) -> Void) {
        client.execute(CoffeeEndpoint.getShippingMethods, completion: completion)
    }
    
    func checkout(shippingMethodId: Int, addressId: String?, tipoPago: String, notes: String?, propina: Double, completion: @escaping (Result<CheckoutResponse, APIError>) -> Void) {
        client.execute(CoffeeEndpoint.checkout(
            shippingMethodId: shippingMethodId,
            addressId: addressId,
            tipoPago: tipoPago,
            notas: notes,
            propina: propina
        ), completion: completion)
    }
    
    func fetchOrders(completion: @escaping (Result<[Order], APIError>) -> Void) {
        client.execute(CoffeeEndpoint.getOrders, completion: completion)
    }
    
    func fetchOrderTracking(orderId: String, completion: @escaping (Result<OrderTracking, APIError>) -> Void) {
        client.execute(CoffeeEndpoint.getOrderTracking(id: orderId), completion: completion)
    }
}
