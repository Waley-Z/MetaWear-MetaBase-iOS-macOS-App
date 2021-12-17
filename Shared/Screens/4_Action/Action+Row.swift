// Copyright 2021 MbientLab Inc. All rights reserved. See LICENSE.MD.

import SwiftUI
import mbientSwiftUI
import Combine
import MetaWear
import MetaWearSync

extension ActionScreen {

    struct Row: View {

        @EnvironmentObject private var action: ActionVM
        @ObservedObject var vm: AboutDeviceVM

        var body: some View {
            HStack(spacing: 10) {

                Images.metawearTop.image()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)

                Text(vm.meta.name)
                    .font(.title2)

                ConnectionButton(state: vm.connection)
                LargeSignalDots(signal: vm.rssi, dotSize: 9, spacing: 3, color: .white)

                HStack {
                    ProgrammingState(vm: vm)
                        .padding(.trailing, 10)

                    ProgressSummary(vm: vm)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .contextMenu { if case ActionState.error = action.state[vm.meta.mac]! {
                Button("Factory Reset") { vm.reset() }
            } }
            .onAppear(perform: vm.onAppear)
            .onDisappear(perform: vm.onDisappear)
            .padding()
            .background(background)
            .animation(.easeOut, value: action.state[vm.meta.mac]!)
        }

        private var background: some View {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(action.actionFocus == vm.meta.mac ? 0.1 : 0))
        }
    }
}
