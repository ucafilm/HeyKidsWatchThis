import Foundation

// MARK: - Storage Directory Types
enum StorageDirectory {
    case documents      // User content, Files app visible, iCloud backed up
    case library        // App support files, backed up but private
    case caches         // Re-downloadable content, system may delete
    case temporary      // Short-term files, deleted after 3 days
    
    var searchPathDirectory: FileManager.SearchPathDirectory {
        switch self {
        case .documents: return .documentDirectory
        case .library: return .libraryDirectory
        case .caches: return .cachesDirectory
        case .temporary: return .documentDirectory
        }
    }
    
    var subdirectory: String? {
        switch self {
        case .temporary: return "tmp"
        default: return nil
        }
    }
    
    var appSubfolder: String {
        return "HeyKidsWatchThis"
    }
}

// MARK: - Storage Error Types
enum StorageError: Error, Equatable, LocalizedError {
    case fileNotFound(String)
    case encodingFailed(String)
    case decodingFailed(String)
    case writePermissionDenied(String)
    case diskFull
    case invalidPath(String)
    case directoryCreationFailed(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .encodingFailed(let details):
            return "Encoding failed: \(details)"
        case .decodingFailed(let details):
            return "Decoding failed: \(details)"
        case .writePermissionDenied(let path):
            return "Write permission denied: \(path)"
        case .diskFull:
            return "Insufficient disk space"
        case .invalidPath(let path):
            return "Invalid path: \(path)"
        case .directoryCreationFailed(let path):
            return "Directory creation failed: \(path)"
        case .unknown(let details):
            return "Unknown error: \(details)"
        }
    }
}
// MARK: - Result Helper Extension
extension Result {
    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
    
    var isFailure: Bool {
        return !isSuccess
    }
}
