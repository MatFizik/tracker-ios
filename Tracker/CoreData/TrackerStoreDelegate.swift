//
//  TrackerStoreDelegate.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate(_ store: TrackerStore)
}
