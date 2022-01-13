// Copyright 2021 MbientLab Inc. All rights reserved. See LICENSE.MD.

import mbientSwiftUI

public protocol ActionHeaderVM: HeaderVM {
    var actionType: ActionType { get }
    var representativeConfig: ModulesConfiguration { get }
    var title: String { get }
    func backToHistory()
}

struct ActionHeader: View {

    let vm: ActionHeaderVM

    @Environment(\.presentationMode) private var nav
    @EnvironmentObject private var routing: Routing
    @State private var didAppear = false
    @Environment(\.namespace) private var namespace

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            HeaderBackButton(overrideBackAction: vm.backToHistory)

            VStack(alignment: .leading, spacing: .init(iPhone: 8, 12)) {
                Text(vm.actionType.title)
                    .adaptiveFont(.screenHeader)
                    .foregroundColor(.myPrimary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .matchedGeometryEffect(id: "HeaderTitle", in: namespace!, properties: .position)

                Text(vm.title)
                    .adaptiveFont(.screenHeaderDetail)
                    .foregroundColor(.mySecondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(idiom.is_iPhone ? (didAppear ? 1 : 0) : 1)
            }
            .offset(y: .init(iPhone: didAppear ? -11 : 0, 0))

            Spacer()

            Header.Icons(vm: vm)
                .padding(.trailing, .screenInset)
                .offset(y: -.headerMinHeight / 5)
        }
        .padding(.top, 10)
        .frame(maxWidth: .infinity, minHeight: .headerMinHeight, alignment: .topLeading)
        .padding(.top, .headerTopPadding)
        .backgroundToEdges(.myBackground)
        .animation(.easeOut, value: didAppear)
        .onAppear { if idiom.is_iPhone { didAppear = true } }
        .onDisappear { if idiom.is_iPhone { didAppear = false } }
        .padding(.bottom, .init(iPhone: .screenInset * 1.5, .screenInset))
    }
}
