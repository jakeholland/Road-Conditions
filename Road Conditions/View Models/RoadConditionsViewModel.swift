import Combine
import Foundation
import MapKit
import RoadConditionsService

final class RoadConditionsViewModel: ObservableObject {
    
    @Published var centerCoordinate = CLLocationCoordinate2D()
    @Published var roadConditionsSegments: [RoadConditionsSegment] = []
    
    private let roadConditionsService: RoadConditionsServiceProtocol

    init(roadConditionsService: RoadConditionsServiceProtocol = RoadConditionsService()) {
        self.roadConditionsService = roadConditionsService
    }
    
    func loadRoadConditions() {
        roadConditionsService.getRoadConditions { result in
            switch result {
            case .success(let roadConditionsSegments):
                DispatchQueue.main.async {
                    self.roadConditionsSegments = roadConditionsSegments
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
