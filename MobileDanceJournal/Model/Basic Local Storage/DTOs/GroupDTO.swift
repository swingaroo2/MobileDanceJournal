//
//  GroupDTO.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 10/12/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

struct GroupDTO: Codable {
    var name: String
    var dateCreated: Date
    var practiceSessions: [PracticeSessionDTO]
    
    private enum CodingKeys: String, CodingKey {
        case name
        case dateCreated
        case practiceSessions
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.dateCreated = try values.decode(Date.self, forKey: .dateCreated)
        self.practiceSessions = try values.decode([PracticeSessionDTO].self, forKey: .practiceSessions)
    }
    
    init(_ group: Group) {
        self.name = group.name
        self.dateCreated = group.dateCreated
        self.practiceSessions = (group.practiceSessions?.allObjects as? [PracticeSessionDTO]) ?? [PracticeSessionDTO]()
    }
}

struct PracticeSessionDTO: Codable {
    var date: Date
    var notes: String
    var title: String
    var group: GroupDTO?
    
    private enum CodingKeys: String, CodingKey {
        case date
        case notes
        case title
        case group
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try values.decode(Date.self, forKey: .date)
        self.notes = try values.decode(String.self, forKey: .notes)
        self.title = try values.decode(String.self, forKey: .title)
        self.group = try values.decode(GroupDTO.self, forKey: .group)
    }
    
    init(_ practiceSession: PracticeSession) {
        self.date = practiceSession.date
        self.notes = practiceSession.notes
        self.title = practiceSession.title
        self.group = practiceSession.group != nil ? GroupDTO(practiceSession.group!) : nil
    }
}
