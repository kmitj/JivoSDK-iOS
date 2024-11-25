//
//  JMTimelineHistory.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 16/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import DTCollectionViewManager
import DTModelStorage

fileprivate class JMTimelineHistoryContext {
    var shouldResetCache: Bool

    init(shouldResetCache: Bool) {
        self.shouldResetCache = shouldResetCache
    }
}

public enum JMTimelineHistoryInsertionDirection {
    case past
    case future
}

public final class JMTimelineHistory {
    private let factory: JMTimelineFactory
    public let cache: JMTimelineCache

    var manager: DTCollectionViewManager!

    private var grouping = JMTimelineGrouping()
    private var earliestItemsMap = [Int: JMTimelineItem]()
    private var registeredFooterModels = [JMTimelineItem]()
    private var registeredItemIDs = Set<String>()
    
    private var isTyping = false

    public init(factory: JMTimelineFactory, cache: JMTimelineCache) {
        self.factory = factory
        self.cache = cache
    }

    public var hasDeferredChanges: Bool {
        // it replaces the default delegate while applying the deferred updates,
        // so we can rely on this replacement
        if manager.memoryStorage.delegate !== manager.collectionViewUpdater {
            return true
        }
        else if let update = manager.memoryStorage.currentUpdate {
            return !update.isEmpty
        }
        else {
            return false
        }
    }

    public var numberOfItems: Int {
        return manager.memoryStorage.totalNumberOfItems
    }

    var earliestIndexPath: IndexPath? {
        let earliestSectionIndex = grouping.historyLastIndex
        guard
            !manager.memoryStorage.sections.isEmpty,
            earliestSectionIndex < manager.memoryStorage.sections.endIndex
            else { return nil }

        let earliestSection = manager.memoryStorage.sections[earliestSectionIndex]
        if earliestSection.numberOfItems == 0 {
            return nil
        }
        else if let earliestItem = earliestSection.item(at: earliestSection.numberOfItems - 1) as? JMTimelineItem {
            return manager.memoryStorage.indexPath(forItem: earliestItem)
        }
        else {
            return nil
        }
    }

    var latestIndexPath: IndexPath? {
        let latestSectionIndex = grouping.historyFrontIndex
        guard
            !manager.memoryStorage.sections.isEmpty,
            latestSectionIndex < manager.memoryStorage.sections.endIndex
            else { return nil }

        let latestSection = manager.memoryStorage.sections[latestSectionIndex]
        if latestSection.numberOfItems == 0 {
            return nil
        }
        else if let latestItem = latestSection.item(at: 0) as? JMTimelineItem {
            return manager.memoryStorage.indexPath(forItem: latestItem)
        }
        else {
            return nil
        }
    }

    func configure(manager: DTCollectionViewManager) {
        self.manager = manager

        manager.memoryStorage.headerModelProvider = { [weak self] section in
            return self?.grouping.group(forSection: section)
        }

        manager.memoryStorage.supplementaryModelProvider = { [weak self] _, indexPath in
            guard let `self` = self else { return nil }
            let index = indexPath.section - self.grouping.historyFrontIndex
            return self.registeredFooterModels.indices.contains(index)
                ? self.registeredFooterModels[index]
                : nil
        }
    }

    public func prepare() {
        grouping.reset()
        manager.memoryStorage.updateWithoutAnimations {
            let items = Array(repeating: [], count: grouping.topIndex - grouping.bottomIndex)
            manager.memoryStorage.setItemsForAllSections(items)
        }
        manager?.collectionViewUpdater?.storageNeedsReloading()
    }

    public func setTopItem(_ item: JMTimelineItem?) -> Bool {
        let section = grouping.topIndex

        if let item = item {
            if let oldIndexPath = manager.memoryStorage.indexPath(forItem: item) {
                manager.memoryStorage.updateWithoutAnimations {
                    manager.memoryStorage.deleteSections([oldIndexPath.section])
                    manager.memoryStorage.setItems([item], forSection: section)
                }
            }
            else {
                manager.memoryStorage.setItems([item], forSection: section)
            }

            return true
        }
        else if manager.memoryStorage.numberOfItems(inSection: section) > 0 {
            manager.memoryStorage.setItems([], forSection: section)
            return true
        }
        else {
            manager.memoryStorage.setItems([], forSection: section)
            return false
        }
    }

    public func setBottomItem(_ item: JMTimelineItem?) -> Bool {
        let section = grouping.bottomIndex

        if let item = item {
            manager.memoryStorage.setItems([item], forSection: section)
            return true
        }
        else if manager.memoryStorage.numberOfItems(inSection: section) > 0 {
            manager.memoryStorage.setItems([], forSection: section)
            return true
        }
        else {
            manager.memoryStorage.setItems([], forSection: section)
            return false
        }
    }

    public func setTyping(item: JMTimelineItem?) {
        let section = grouping.typingIndex

        switch (item, isTyping) {
        case (nil, false):
            break
        case (nil, true):
            isTyping = false
            if let existingItem = manager.memoryStorage.items(inSection: section)?.first as? JMTimelineItem {
                try? manager.memoryStorage.removeItem(existingItem)
            }
        case (let payload, false):
            isTyping = true
            manager.memoryStorage.addItem(payload, toSection: section)
        case (let payload, true):
            manager.memoryStorage.setItems([payload], forSection: section)
        }
    }

    public func item(at indexPath: IndexPath) -> JMTimelineItem? {
        return manager.memoryStorage.item(at: indexPath) as? JMTimelineItem
    }

    public func item(byUUID uuid: String) -> JMTimelineItem? {
        for section in manager.memoryStorage.sections {
            for index in 0 ..< section.numberOfItems {
                guard let item = section.item(at: index) as? JMTimelineItem else { continue }
                guard uuid == item.uid else { continue }
                return item
            }
        }

        return nil
    }

    public func fill(with items: [JMTimelineItem]) {
        earliestItemsMap.removeAll()
        registeredItemIDs.removeAll()
        registeredFooterModels.removeAll()

        prepare()
        prepend(items: items, resetCache: true)
    }
    
    public func insert(items: [JMTimelineItem], direction: JMTimelineHistoryInsertionDirection, keepPosition: Bool) {
        guard !items.isEmpty
        else {
            return
        }
        
        manager.memoryStorage.performUpdates {
            do {
                let groups = Dictionary(grouping: items, by: \.groupingDay).sorted { $0.key > $1.key }
                for group in groups {
                    let maybeRegisteredItems = Dictionary(grouping: group.value, by: {registeredItemIDs.contains($0.uid)})
                    let newItems = maybeRegisteredItems[false] ?? Array()
                    let existingItems = maybeRegisteredItems[true] ?? Array()
                    
                    defer {
                        for item in existingItems {
                            cache.resetSize(for: item.uid)
                            try manager.memoryStorage.reloadItem(item)
                        }
                        
                        registeredItemIDs.formUnion(newItems.map(\.uid))
                    }
                    
                    let section: Int
                    if let index = grouping.section(for: group.key) {
                        section = index
                    }
                    else if let index = grouping.grow(date: group.key) {
                        let footerIndex = index - grouping.historyFrontIndex
                        registeredFooterModels.insert(factory.generateItem(for: group.key), at: footerIndex)

                        configureMargins(
                            surroundingItems: Array(),
                            newItems: newItems,
                            grouping: .keep)
                        
                        let model = SectionModel()
                        model.setItems(newItems)
                        manager.memoryStorage.insertSection(model, atIndex: index)
                        continue
                    }
                    else {
                        assertionFailure()
                        continue
                    }
                    
                    let currentItems = (manager.memoryStorage.items(inSection: section) as? [JMTimelineItem]) ?? Array()

                    if let latestItem = currentItems.first, let endItem = newItems.last, endItem.isLater(than: latestItem) {
                        configureMargins(
                            surroundingItems: currentItems,
                            newItems: newItems,
                            grouping: .keep)
                        
                        try manager.memoryStorage.insertItems(newItems, at: IndexPath(item: 0, section: section))
                    }
                    else if let earliestItem = currentItems.last, let beginItem = newItems.first, beginItem.isEarlier(than: earliestItem) {
                        configureMargins(
                            surroundingItems: currentItems,
                            newItems: newItems,
                            grouping: .keep)
                        
                        try manager.memoryStorage.addItems(newItems, toSection: section)
                    }
                    else if !currentItems.isEmpty {
                        configureMargins(
                            surroundingItems: currentItems,
                            newItems: newItems,
                            grouping: .keep)
                        
                        switch direction {
                        case .past:
                            let insertionDate = newItems.map(\.date).max() ?? Date()
                            if let location = currentItems.enumerated().reversed().first(where: { _, element in element.isLater(than: insertionDate) }) {
                                try manager.memoryStorage.insertItems(newItems, at: IndexPath(item: location.offset + 1, section: section))
                            }
                            
                        case .future:
                            let insertionDate = newItems.map(\.date).min() ?? Date()
                            if let location = currentItems.enumerated().first(where: { _, element in element.isEarlier(than: insertionDate) }) {
                                let indexPath = IndexPath(item: location.offset, section: section)
                                try manager.memoryStorage.insertItems(newItems, at: indexPath)
                            }
                        }
                    }
                }
            }
            catch {
                assertionFailure()
            }
        }
    }

    public func populate(withItems items: [JMTimelineItem]) {
        let groups = Dictionary(grouping: items, by: \.groupingDay)
        var itemsToReload = Set<JMTimelineItem>()

        items.forEach { item in
            let neighbourItems = groups[item.groupingDay] ?? Array()
            
            if let existingGroupIndex = grouping.section(for: item.groupingDay),
               let groupItems = manager.memoryStorage.items(inSection: existingGroupIndex)?.compactMap({ $0 as? JMTimelineItem }) {
                if let place = findPlaceToInsert(item, withinGroup: groupItems) {
                    itemsToReload.formUnion(
                        configureMargins(
                            surroundingItems: neighbourItems + [place.later?.item, place.earlier.item].compactMap{$0},
                            newItems: [item],
                            grouping: (place.later == nil ? .closeAtBottom : .keep))
                    )
                    
                    do {
                        let location = IndexPath(item: place.earlier.index, section: existingGroupIndex)
                        try manager.memoryStorage.insertItem(item, to: location)
                    }
                    catch {
                        print("\n\nMemoryStorage.insertItem(_:to:) instance method throwed an exception: \(error.localizedDescription)\n\n")
                    }
                }
                else {
                    itemsToReload.formUnion(
                        configureMargins(
                            surroundingItems: Array(),
                            newItems: [item],
                            grouping: .openAtTop)
                    )
                    
                    do {
                        let location = IndexPath(item: groupItems.count, section: existingGroupIndex)
                        try manager.memoryStorage.insertItem(item, to: location)
                    }
                    catch {
                        print("\n\nMemoryStorage.insertItem(_:to:) instance method throwed an exception: \(error.localizedDescription)\n\n")
                    }
                }
            }
            else {
                guard let newGroupIndex = grouping.grow(date: item.groupingDay)
                else {
                    return print("\n\nThere is an internal bug occured while populating timeline with new items: JMTimelineGrouping.section(for:) method didn't find any existing group for item date (\(item.groupingDay)), but JMTimelineGrouping.grow(date:) found.\n\n")
                }
                
                itemsToReload.formUnion(
                    configureMargins(
                        surroundingItems: Array(),
                        newItems: [item],
                        grouping: [.openAtTop, .closeAtBottom])
                )
                
                let groupingItem = factory.generateItem(for: item.groupingDay)
                registeredFooterModels.insert(groupingItem, at: newGroupIndex - grouping.historyFrontIndex)
                
                let section = SectionModel()
                section.setItems([item])
                manager.memoryStorage.insertSection(section, atIndex: newGroupIndex)
            }
            
            registeredItemIDs.insert(item.uid)
        }
        
        itemsToReload.subtracting(items).forEach {
            cache.resetSize(for: $0.uid)
            manager.memoryStorage.reloadItem($0)
        }
    }
    
    /**
     earlier.element will be move to next index in section after item will be inserted at earlier.offset
     */
    private func findPlaceToInsert(_ item: JMTimelineItem, withinGroup groupItems: [JMTimelineItem]) -> (earlier: GroupItemPlacement, later: GroupItemPlacement?)? {
        guard let pair = groupItems
            .enumerated()
            .first(where: {!item.isEarlier(than: $1)})
        else {
            return nil
        }
        
        return (
            earlier: GroupItemPlacement(index: pair.offset, item: pair.element),
            later: (
                pair.offset > .zero
                ? GroupItemPlacement(index: pair.offset - 1, item: groupItems[pair.offset - 1])
                : nil
            )
        )
    }
    
    /// Adds or removes rendering options for passed JMTimelineItem objects using one of several item bounds options
    /// - Parameters:
    ///  - items: Array of JMTimelineItem objects to which the rendering options changes is applied. Must be passed in the same order as they arranged in its own CollectionView section.
    ///  - option: an option specifying the rendering options applying to bound items way.

    @discardableResult
    private func configureMargins(surroundingItems: [JMTimelineItem], newItems: [JMTimelineItem], grouping: MarginsGrouping) -> Set<JMTimelineItem> {
        var itemsToReload = Set<JMTimelineItem>()
        
        let leadingLayoutOptions = JMTimelineLayoutOptions([.groupTopMargin, .groupFirstElement])
        let trailingLayoutOptions = JMTimelineLayoutOptions([.groupBottomMargin, .groupLastElement])

        let items = Set(surroundingItems + newItems).sorted { $0.isLater(than: $1) }
        _ = items.reduce(nil) { laterItem, earlierItem -> JMTimelineItem in
            guard let laterItem = laterItem
            else {
                return earlierItem
            }
            
            if earlierItem.groupingID == laterItem.groupingID {
                if !laterItem.layoutOptions.intersection(leadingLayoutOptions).isEmpty {
                    laterItem.removeLayoutOptions(leadingLayoutOptions)
                    itemsToReload.insert(laterItem)
                }
                
                if !earlierItem.layoutOptions.intersection(trailingLayoutOptions).isEmpty {
                    earlierItem.removeLayoutOptions(trailingLayoutOptions)
                    itemsToReload.insert(earlierItem)
                }
            }
            else {
                if !laterItem.layoutOptions.isSuperset(of: leadingLayoutOptions) {
                    laterItem.addLayoutOptions(leadingLayoutOptions)
                    itemsToReload.insert(laterItem)
                }
                
                if !earlierItem.layoutOptions.isSuperset(of: trailingLayoutOptions) {
                    earlierItem.addLayoutOptions(trailingLayoutOptions)
                    itemsToReload.insert(earlierItem)
                }
            }
            
            return earlierItem
        }
        
        if grouping.contains(.openAtTop), let earliestItem = items.last {
            earliestItem.addLayoutOptions(leadingLayoutOptions)
            itemsToReload.insert(earliestItem)
        }
        
        if grouping.contains(.closeAtBottom), let latestItem = items.first {
            latestItem.addLayoutOptions(trailingLayoutOptions)
            itemsToReload.insert(latestItem)
        }
        
        return itemsToReload
    }

    public func append(items: [JMTimelineItem]) {
        manager.memoryStorage.performUpdates {
            items.forEach { item in
                let messageClearDate = item.groupingDay

                if let groupIndex = grouping.grow(date: messageClearDate) {
                    let footerIndex = groupIndex - grouping.historyFrontIndex
                    registeredFooterModels.insert(factory.generateItem(for: messageClearDate), at: footerIndex)
                    
                    let model = SectionModel()
                    model.setItems([item])
                    manager.memoryStorage.insertSection(model, atIndex: grouping.historyFrontIndex)
                }
                else {
                    append_configureAndStore(item: item)
                }

                registeredItemIDs.insert(item.uid)
            }
        }
        manager.collectionViewUpdater?.storageNeedsReloading()
    }

    public func append(item: JMTimelineItem) {
        append(items: [item])
    }

    private func append_configureAndStore(item newerItem: JMTimelineItem) {
        let indexPath = IndexPath(item: 0, section: grouping.historyFrontIndex)
        defer {
            try? manager.memoryStorage.insertItem(newerItem, to: indexPath)
        }

        newerItem.removeLayoutOptions(.groupBottomMargin)
        guard let olderItem = manager.memoryStorage.item(at: indexPath) as? JMTimelineItem
        else {
            return
        }

        if let newerGroupingID = newerItem.groupingID, let olderGroupingID = olderItem.groupingID, newerGroupingID != olderGroupingID {
            olderItem.addLayoutOptions(.groupBottomMargin)
            cache.resetSize(for: olderItem.uid)
            manager.memoryStorage.reloadItem(olderItem)

            newerItem.addLayoutOptions(.groupTopMargin)
        }
        else {
            olderItem.removeLayoutOptions([.groupLastElement, .groupBottomMargin])
            cache.resetSize(for: olderItem.uid)
            manager.memoryStorage.reloadItem(olderItem)

            newerItem.removeLayoutOptions([.groupFirstElement, .groupTopMargin])
            cache.resetSize(for: newerItem.uid)
        }
    }
    
    public func prepend(items: [JMTimelineItem], resetCache: Bool) {
        for (day, groupItems) in Dictionary(grouping: items, by: \.groupingDay) {
            let groupIndex = grouping.section(for: day) ?? .max
            let surroundingItems = (manager.memoryStorage.items(inSection: groupIndex) ?? Array()) as [JMTimelineItem]
            
            configureMargins(
                surroundingItems: surroundingItems,
                newItems: groupItems,
                grouping: .keep)
        }
        
        let context = JMTimelineHistoryContext(shouldResetCache: resetCache)
        manager.memoryStorage.performUpdates {
            items.forEach { item in
                if registeredItemIDs.contains(item.uid) {
                    cache.resetSize(for: item.uid)
                    manager.memoryStorage.reloadItem(item)
                    return
                }
                
                let messageClearDate = item.groupingDay

                if let groupIndex = grouping.section(for: messageClearDate) {
                    prepend_configureAndStore(context: context, item: item, into: groupIndex)
                }
                else if let groupIndex = grouping.grow(date: messageClearDate) {
                    let footerIndex = groupIndex - grouping.historyFrontIndex
                    registeredFooterModels.insert(factory.generateItem(for: messageClearDate), at: footerIndex)

                    let model = SectionModel()
                    manager.memoryStorage.insertSection(model, atIndex: groupIndex)
                    prepend_configureAndStore(context: context, item: item, into: groupIndex)
                }
            }
        }
    }

    private func prepend_configureAndStore(context: JMTimelineHistoryContext, item: JMTimelineItem, into groupIndex: Int) {
        if let newerItem = earliestItemsMap[groupIndex] {
            if item.isLater(than: newerItem) {
                prepare_uniteGroupMates(context: context, olderItem: newerItem, newerItem: item)
            }
            else {
                prepare_uniteGroupMates(context: context, olderItem: item, newerItem: newerItem)
                earliestItemsMap[groupIndex] = item
            }
        }
        else {
            item.removeLayoutOptions([.groupBottomMargin])
            earliestItemsMap[groupIndex] = item
        }

        manager.memoryStorage.addItem(item, toSection: groupIndex)
        
        registeredItemIDs.insert(item.uid)
    }

    private func prepare_uniteGroupMates(context: JMTimelineHistoryContext, olderItem: JMTimelineItem, newerItem: JMTimelineItem) {
        guard belongToSameGroup(olderItem, newerItem) else {
            return
        }

        newerItem.removeLayoutOptions([.groupTopMargin, .groupFirstElement])
        olderItem.removeLayoutOptions([.groupLastElement, .groupBottomMargin])

        if context.shouldResetCache {
            cache.resetSize(for: newerItem.uid)
            cache.resetSize(for: olderItem.uid)
            context.shouldResetCache = false
        }
    }

    public func replaceItem(byUUID UUID: String, with replacingItem: JMTimelineItem) {
        for section in manager.memoryStorage.sections {
            for index in 0 ..< section.numberOfItems {
                guard let item = section.item(at: index) as? JMTimelineItem,
                      UUID == item.uid
                else {
                    continue
                }
                
                configureMargins(
                    surroundingItems: Array() + [
                        (index > 0 ? section.item(at: index - 1) as? JMTimelineItem : nil),
                        (index < section.numberOfItems ? section.item(at: index + 1) as? JMTimelineItem : nil),
                    ].compactMap{$0},
                    newItems: [replacingItem],
                    grouping: .keep)
                
                cache.resetSize(for: UUID)
                try? manager.memoryStorage.replaceItem(item, with: replacingItem)

                return
            }
        }
    }

    public func removeItem(byUUID UUID: String) {
        guard let itemToRemove = item(byUUID: UUID) as? JMTimelineItem
        else {
            return
        }
        
        try? manager.memoryStorage.removeItem(itemToRemove)
        
        guard let section = grouping.section(for: itemToRemove.groupingDay),
              let groupItems = manager.memoryStorage.items(inSection: section)?.compactMap({ $0 as? JMTimelineItem })
        else {
            return
        }
        
        if let place = findPlaceToInsert(itemToRemove, withinGroup: groupItems) {
            configureMargins(
                surroundingItems: [place.later?.item, place.earlier.item].compactMap{$0},
                newItems: Array(),
                grouping: MarginsGrouping()
                    .union(groupItems.last == place.earlier.item ? .openAtTop : [])
                    .union(groupItems.first == place.later?.item || groupItems.first == place.earlier.item ? .closeAtBottom : []))
        }
        else {
            configureMargins(
                surroundingItems: [groupItems.last].compactMap{$0},
                newItems: Array(),
                grouping: .openAtTop)
        }
    }

    private func belongToSameGroup(_ firstItem: JMTimelineItem, _ secondItem: JMTimelineItem) -> Bool {
        if let firstGroupingID = firstItem.groupingID, let secondGroupingID = secondItem.groupingID {
            return (firstGroupingID == secondGroupingID)
        }
        else {
            return false
        }
    }
}

extension JMTimelineHistory {
    struct MarginsGrouping: OptionSet {
        let rawValue: Int
        static let keep = Self(rawValue: 0 << 0)
        static let openAtTop = Self(rawValue: 1 << 0)
        static let closeAtBottom = Self(rawValue: 1 << 1)
    }
    
    struct GroupItemPlacement {
        let index: Int
        let item: JMTimelineItem
    }
}

fileprivate extension JMTimelineItem {
    var groupingDay: Date {
        return date.withoutTime()
    }
    
    func isLater(than anotherItem: JMTimelineItem) -> Bool {
        return (date > anotherItem.date)
    }
    
    func isLater(than anotherDate: Date) -> Bool {
        return (date > anotherDate)
    }
    
    func isEarlier(than anotherItem: JMTimelineItem) -> Bool {
        return (date < anotherItem.date)
    }
    
    func isEarlier(than anotherDate: Date) -> Bool {
        return (date < anotherDate)
    }
}
