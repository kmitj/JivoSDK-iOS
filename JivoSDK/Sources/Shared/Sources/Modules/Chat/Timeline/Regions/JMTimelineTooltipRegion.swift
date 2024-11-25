//
//  JMTimelineTooltipRegion.swift
//  App
//
//  Created by Stan Potemkin on 26.01.2022.
//  Copyright © 2022 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

final class JMTimelineTooltipRegion: JMTimelineMessageCanvasRegion {
    private let plainBlock = JMTimelineCompositePlainBlock()
    
    init() {
        super.init(renderMode: .content(time: .omit))
        integrateBlocks([plainBlock], gap: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup(uid: String, info: Any, meta: JMTimelineMessageMeta?, options: JMTimelineMessageRegionRenderOptions, provider: JVChatTimelineProvider, interactor: JVChatTimelineInteractor) {
        super.setup(
            uid: uid,
            info: info,
            meta: meta,
            options: options,
            provider: provider,
            interactor: interactor)

        if let info = info as? JMTimelineMessagePlainInfo {
            plainBlock.configure(
                content: info.text,
                style: info.style,
                provider: provider,
                interactor: interactor)
        }
    }
    
//    override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineCompositeStyle.self)
//        let contentStyle = style.contentStyle.convert(to: JMTimelinePhotoStyle.self)
//
//        imageBlock.waitingIndicatorStyle = contentStyle.waitingIndicatorStyle
//
//        imageBlock.apply(
//            style: JMTimelineCompositePhotoStyle(
//                ratio: contentStyle.ratio,
//                contentMode: contentStyle.contentMode,
//                errorStubBackgroundColor: contentStyle.errorStubStyle.backgroundColor,
//                errorStubDescriptionColor: contentStyle.errorStubStyle.errorDescriptionColor
//            )
//        )
//    }
}
