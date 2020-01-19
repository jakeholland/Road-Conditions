import MapKit

public final class RoadConditionsMultiPolyline: MKMultiPolyline {
    public let roadConditions: RoadConditions
    
    init?(_ geoJsonFeature: MKGeoJSONFeature) {
        let polylines = geoJsonFeature.geometry.compactMap { $0 as? MKPolyline }
        guard
            !polylines.isEmpty,
            let properties = geoJsonFeature.properties,
            let conditions = try? JSONDecoder().decode(IllinoisWinterRoadConditionsResponse.self, from: properties),
            let roadConditionsString = conditions.Cond_Desc,
            let roadConditions = RoadConditions(rawValue: roadConditionsString)
            else { return nil }
        
        self.roadConditions = roadConditions
        super.init(polylines)
    }
}

public extension Array where Element == RoadConditionsMultiPolyline {
    var polylines: [MKPolyline] { flatMap { $0.polylines } }
}