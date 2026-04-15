import Foundation

struct MovieDetails: Equatable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDateText: String
    let genres: [String]
    let overview: String
    let homepage: String?
    let budget: Int
    let revenue: Int
    let spokenLanguages: [String]
    let status: String
    let runtime: Int?

    var releaseMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: releaseDateText) else {
            return releaseDateText
        }

        let output = DateFormatter()
        output.dateFormat = "MMMM yyyy"
        return output.string(from: date)
    }
}
