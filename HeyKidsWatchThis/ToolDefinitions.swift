// ToolDefinitions.swift
// Essential tool definitions for DiscussionQuestionService

import Foundation

/// Tool definition for discussion question generation
struct Tool {
    let name: String
    let description: String
    
    init(name: String, description: String) {
        self.name = name
        self.description = description
    }
}

/// Protocol for tool-based services
protocol ToolCallable {
    var tools: [Tool] { get }
    func call(_ tool: Tool) async throws -> String
}
