import Foundation

protocol XcodeBuildCoverageParsing {
    static func coverage(xcresultBundlePath: String, files: [String], excludedTargets: [String]) throws -> Report
}

enum XcodeBuildCoverageParser: XcodeBuildCoverageParsing {
    static func coverage(xcresultBundlePath: String, files: [String], excludedTargets: [String]) throws -> Report {
        return try coverage(xcresultBundlePath: xcresultBundlePath, files: files, excludedTargets: excludedTargets, coverageFileFinder: XcodeCoverageFileFinder.self, xcCovParser: XcCovJSONParser.self)
    }

    static func coverage(xcresultBundlePath: String, files: [String], excludedTargets: [String], coverageFileFinder: XcodeCoverageFileFinding.Type, xcCovParser: XcCovJSONParsing.Type) throws -> Report {
        let coverageFile = try coverageFileFinder.coverageFile(xcresultBundlePath: xcresultBundlePath)

        let data = try xcCovParser.json(fromXCoverageFile: coverageFile)
        var coverage = try JSONDecoder().decode(XcodeBuildCoverage.self, from: data)
        coverage = coverage.filteringTargets(notOn: files, excludedTargets: excludedTargets)

        let targets = coverage.targets.map { ReportSection(fromTarget: $0) }
        let messages = !targets.isEmpty ? ["Project coverage: \(coverage.percentageCoverage.description)%"] : []

        return Report(messages: messages, sections: targets)
    }
}
