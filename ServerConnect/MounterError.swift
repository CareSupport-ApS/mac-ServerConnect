//
//  MounterError.swift
//  ServerConnect
//
//  Created by Emil Møller Lind on 19/01/2024.
//

import Foundation

enum MounterError: Error {
    case errorCreatingMountFolder
    case errorCheckingMountDir
    case errorOnEncodingShareURL
    case invalidMountURL
    case invalidHost
    case mountpointInaccessible
    case couldNotTestConnectivity
    case invalidMountOptions
    case alreadyMounted
    case mountIsQueued
    case targetNotReachable
    case otherError
    case noRouteToHost
    case doesNotExist
    case shareDoesNotExist
    case unknownReturnCode
    case invalidMountPath
    case unmountFailed
    case timedOutHost
    case authenticationError
    case hostIsDown
    case userUnmounted
    case noError
}

extension MounterError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .errorCreatingMountFolder:
            return NSLocalizedString(
                "Error creating mount directory",
                comment: "Error creating mount directory"
            )
        case .errorCheckingMountDir:
            return NSLocalizedString(
                "Error creating mount directory",
                comment: "Error creating mount directory"
            )
        case .errorOnEncodingShareURL:
            return NSLocalizedString(
                "Cannot encode server URL",
                comment: "Cannot encode server URL"
            )
        case .invalidMountURL:
            return NSLocalizedString(
                "The path to the network share is invalid",
                comment: "The path to the network share is invalid"
            )
        case .invalidHost:
            return NSLocalizedString(
                "Hostname is invalid",
                comment: "Hostname is invalid"
            )
        case .mountpointInaccessible:
            return NSLocalizedString(
                "Mountpoint is inacessible",
                comment: "Mountpoint is inacessible"
            )
        case .couldNotTestConnectivity:
            return NSLocalizedString(
                "Network connectivity cannot be tested",
                comment: "Network connectivity cannot be tested"
            )
        case .invalidMountOptions:
            return NSLocalizedString(
                "Invalid mount options",
                comment: "Invalid mount options"
            )
        case .alreadyMounted:
            return NSLocalizedString(
                "Share is already mounted",
                comment: "Share is already mounted"
            )
        case .mountIsQueued:
            return NSLocalizedString(
                "Mount queued",
                comment: "Mount queued"
            )
        case .targetNotReachable:
            return NSLocalizedString(
                "Target host is not reachable",
                comment: "Target host is not reachable"
            )
        case .otherError:
            return NSLocalizedString(
                "Other error",
                comment: "Other error"
            )
        case .noRouteToHost:
            return NSLocalizedString(
                "Hostname error or no route to host",
                comment: "Hostname error or no route to host"
            )
        case .doesNotExist:
            return NSLocalizedString(
                "Does not exist",
                comment: "Does not exist"
            )
        case .shareDoesNotExist:
            return NSLocalizedString(
                "Share does not exist",
                comment: "Share does not exist"
            )
        case .unknownReturnCode:
            return NSLocalizedString(
                "Unknown return code, sorry",
                comment: "Unknown return code, sorry"
            )
        case .invalidMountPath:
            return NSLocalizedString(
                "Invalid mount path",
                comment: "Invalid mount path"
            )
        case .unmountFailed:
            return NSLocalizedString(
                "Cannot unmount share",
                comment: "Cannot unmount share"
            )
        case .timedOutHost:
            return NSLocalizedString(
                "Timeout on reaching host",
                comment: "Timeout on reaching host"
            )
        case .authenticationError:
            return NSLocalizedString(
                "Authentication error",
                comment: "Authentication error"
            )
        case .hostIsDown:
            return NSLocalizedString(
                "Host is down",
                comment: "Host is down"
            )
        case .userUnmounted:
            return NSLocalizedString(
                "User-mounted share",
                comment: "CoUser-mounted sharemment"
            )
        case .noError:
            return NSLocalizedString(
                "no error occured",
                comment: "no error occured"
            )
        }
    }
}
