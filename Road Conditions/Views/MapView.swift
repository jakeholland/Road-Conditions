import MapKit
import RoadConditionsService
import SwiftUI
import UIKit

struct MapView: UIViewRepresentable {
    
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var roadConditionsSegments: [RoadConditionsMultiPolyline]
    @Binding var roadConditionsRegions: [RoadConditionsMultiPolygon]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        let currentPolylines = view.overlays.compactMap { $0 as? MKPolyline }
        let polylines = roadConditionsSegments.polylines
        context.coordinator.roadConditionsSegments = roadConditionsSegments
        
        let currentPolygons = view.overlays.compactMap { $0 as? MKPolygon }
        let polygons = roadConditionsRegions.polygons
        context.coordinator.roadConditionsRegions = roadConditionsRegions
        
        guard currentPolylines != polylines || currentPolygons != polygons else { return }
        
        view.removeAllOverlays()
        view.addOverlays(polylines + polygons)
        view.zoom(to: polylines, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var roadConditionsSegments: [RoadConditionsMultiPolyline] = []
        var roadConditionsRegions: [RoadConditionsMultiPolygon] = []

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            polygonRenderer(for: overlay) ?? polylineRenderer(for: overlay) ?? MKOverlayRenderer(overlay: overlay)
        }
        
        private func polylineRenderer(for overlay: MKOverlay) -> MKPolylineRenderer? {
            guard let roadConditionsSegment = overlay as? RoadConditionsMultiPolyline else { return nil }

            let polylineRenderer = MKPolylineRenderer(overlay: roadConditionsSegment)
            polylineRenderer.strokeColor = roadConditionsSegment.roadConditions.color
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        
        private func polygonRenderer(for overlay: MKOverlay) -> MKPolygonRenderer? {
            guard let roadConditionsRegion = overlay as? RoadConditionsMultiPolygon else { return nil }
            
            let polygonRenderer = MKPolygonRenderer(overlay: roadConditionsRegion)
            polygonRenderer.fillColor = roadConditionsRegion.roadConditions.color.withAlphaComponent(0.1)
            return polygonRenderer
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var exampleCoodinate: CLLocationCoordinate2D = .init(latitude: 51.5, longitude: -0.13)
    
    static var previews: some View {
        MapView(centerCoordinate: .constant(exampleCoodinate),
                roadConditionsSegments: .constant([]),
                roadConditionsRegions: .constant([]))
    }
}
