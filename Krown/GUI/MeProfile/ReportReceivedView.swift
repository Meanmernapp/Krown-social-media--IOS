//
//  ReportReceivedView.swift
//  Krown
//
//  Created by Ivan Kodrnja on 29.05.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI

struct ReportReceivedView: View {
    var body: some View {
        Text("Report Received")
            .font(MainFont.medium.with(size: 42))
            .foregroundColor(.slateGrey)

        Image("right")
            .scaledToFit()
    }
}

struct ReportReceivedView_Previews: PreviewProvider {
    static var previews: some View {
        ReportReceivedView()
    }
}
