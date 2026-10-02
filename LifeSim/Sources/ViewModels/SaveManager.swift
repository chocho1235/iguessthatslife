import Foundation

enum SaveManager {
    private static var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("lifesim_save.json")
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        // Job.maxSalaryMultiplier defaults to .infinity, which standard JSON
        // can't represent as a number.
        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "inf", negativeInfinity: "-inf", nan: "nan")
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "inf", negativeInfinity: "-inf", nan: "nan")
        return decoder
    }

    static func save(_ character: Character) {
        guard let data = try? encoder.encode(character) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func load() -> Character? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? decoder.decode(Character.self, from: data)
    }

    static func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
