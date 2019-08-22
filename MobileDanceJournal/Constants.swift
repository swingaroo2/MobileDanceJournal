//
//  Constants.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 4/21/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation

// MARK: String constants
struct Storyboards {
    static let main = "Main"
}

struct SegueIdentifiers {
    static let showDetailToEdit = "showDetailToEdit"
    static let showDetailNew = "showDetailNew"
}

struct VCConstants {
    static let newPracticeSessionBuilderVCTitle = "New Practice Session"
    static let practiceGroupsVCTitle = "Groups"
    static let chooseVideo = "Choose Video"
    static let videos = "Videos"
}

struct CellIdentifiers {
    static let genericCell = "Cell"
    static let videoCell = "VideoCell"
}

struct AlertConstants {
    static let recordVideo = "Record video"
    static let uploadFromPhotos = "Import from Photos"
    static let addVideo = "Add Video"
}

struct TextConstants {
    static let noContent = "No Content"
    static let editing = "Editing..."
    static let uncategorized = "Uncategorized"
}

struct Actions {
    static let delete = "Delete"
    static let cancel = "Cancel"
    static let ok = "OK"
    static let edit = "Edit"
    static let share = "Share"
    static let move = "Move"
}

struct PlaceholderText {
    static let newPracticeSession = "New Practice Session"
    static let tapToEditContent = "Record notes on your practice session here"
}

struct CustomImages {
    static let addVideo = "add_video"
    static let videoGallery = "video_gallery"
}

// MARK: Errors
struct UserErrors {
    static let textFieldContentsInvalid = "Text field contents are not valid."
    static let videoAlreadyExists = "This video has already been uploaded"
    static let deleteError = "Deletion Error"
    static let failedToGetLinkToVideo = "Failed to get link to selected video"
    static let noPracticeSession = "Failed to find the currently-selected practice session"
}

struct InternalErrors {
    static let failedToGetReferenceToDetailVC = "Could not get reference to PracticeNotepadVC"
}

struct VideoUploadErrors {
    static let generic = "Video upload failed"
    static let serviceUnavailable = "Upload service unavailable"
    static let thumbnailFailedCopy = "Failed to get thumbnail from video"
    static let lostVideo = "We forgot where we saved your video. Sorry about that."
    static let noURL = "Photos was a meanie-head and didn't give us your video. We apologize for the inconvenience."
}

// MARK: Core Data
struct Predicates {
    static let hasGroup = "group == %@"
    static let hasNoGroup = "group == nil"
    static let hasPracticeSession = "practiceSession == %@"
    static let hasPracticeSessionWithFilename = "practiceSession == %@ AND filename == %@"
}

struct ModelConstants {
    static let modelName = "DataModel"
}

struct GroupConstants {
    static let managedObject = "Group"
    static let name = "name"
    static let dateCreated = "dateCreated"
}

struct PracticeSessionConstants {
    static let managedObject = "PracticeSession"
    static let title = "title"
    static let date = "date"
    static let topic = "topic"
    static let partners = "partners"
    static let notes = "notes"
}

struct PracticeVideoConstants {
    static let managedObject = "PracticeVideo"
    static let title = "title"
    static let uploadDate = "uploadDate"
    static let url = "url"
}

// MARK: Enums
enum DateFormats: String {
    case longFormat = "'Started' MMMM dd, yyyy 'at' h:mm:ss.SSSS a"
    case displayFormat = "'Started' MMMM dd, yyyy"
}

enum Permissions {
    case camera
    case photos
}

