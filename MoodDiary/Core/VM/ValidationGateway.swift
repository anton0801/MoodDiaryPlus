import Firebase
import FirebaseDatabase

protocol ValidationGateway {
    func validate() async throws -> Bool
}

final class FirebaseValidationGateway: ValidationGateway {
    func validate() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            Database.database().reference().child("users/log/data")
                .observeSingleEvent(of: .value) { snapshot in
                    if let url = snapshot.value as? String,
                       !url.isEmpty,
                       URL(string: url) != nil {
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                } withCancel: { error in
                    continuation.resume(throwing: error)
                }
        }
    }
}
