import SwiftUI
import MapKit

struct ContentView: View {
    @State private var searchText = ""
    @State private var searchResults: [MKLocalSearchCompletion] = []
    @StateObject private var completer = LocalSearchCompleter()
    @State private var selectedCity = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if !selectedCity.isEmpty {
                    Text("📍 Valgt sted: \(selectedCity)")
                        .padding(.horizontal)
                        .font(.subheadline)
                }

                List(searchResults, id: \.self) { result in
                    Button(action: {
                        getCoordinates(for: result) { coordinate in
                            if let coordinate = coordinate {
                                LocationManager.shared.save(lat: coordinate.latitude, lon: coordinate.longitude, cityName: result.title)
                                self.selectedCity = result.title  // ✅ ADD THIS
                                print("✅ Saved \(result.title) at \(coordinate.latitude), \(coordinate.longitude)")
                            } else {
                                print("❌ Could not get coordinates")
                            }
                        }
                    }) {
                        VStack(alignment: .leading) {
                            Text(result.title)
                            if !result.subtitle.isEmpty {
                                Text(result.subtitle).font(.caption).foregroundColor(.gray)
                            }
                        }
                    }

                }
                .navigationTitle("Søk etter sted")
                .searchable(text: $searchText)
                .onChange(of: searchText) {
                    completer.updateSearch(query: searchText) { results in
                        self.searchResults = results
                    }
                }
            }
        }
    }
}

// 🔍 Auto-complete handler
class LocalSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    private var completer = MKLocalSearchCompleter()
    private var completionHandler: (([MKLocalSearchCompletion]) -> Void)?

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }

    func updateSearch(query: String, onComplete: @escaping ([MKLocalSearchCompletion]) -> Void) {
        completionHandler = onComplete
        completer.queryFragment = query
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completionHandler?(completer.results)
    }
}

// 📍 Convert MKLocalSearchCompletion to coordinates
func getCoordinates(for completion: MKLocalSearchCompletion, completionHandler: @escaping (CLLocationCoordinate2D?) -> Void) {
    let searchRequest = MKLocalSearch.Request(completion: completion)
    let search = MKLocalSearch(request: searchRequest)

    search.start { response, error in
        if let coordinate = response?.mapItems.first?.placemark.coordinate {
            completionHandler(coordinate)
        } else {
            completionHandler(nil)
        }
    }
}
