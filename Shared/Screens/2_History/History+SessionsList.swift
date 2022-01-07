// Copyright 2021 MbientLab Inc. All rights reserved. See LICENSE.MD.

import mbientSwiftUI

extension HistoryScreen {

    struct SessionsList: View {

        init(_ factory: UIFactory) {
            _vm = .init(wrappedValue: factory.makePastSessionsVM())
        }

        @StateObject var vm: HistoricalSessionsVM
        @State private var selection: Session? = nil
        @State private var dateWidth = CGFloat(50)
        @State private var timeWidth = CGFloat(50)

        var body: some View {
            VStack {
                Subhead(label: "Prior Sessions")

                List(selection: $selection) {
                    ForEach(vm.sessions) { session in
                        Row(session: session,
                            dateWidth: dateWidth,
                            timeWidth: timeWidth)
                            .tag(session)
                    }
                    Color.clear.frame(height: 25)
                }
                .mask(mask.offset(y: 1))
                .onPreferenceChange(DateWK.self) { dateWidth = $0 }
                .onPreferenceChange(TimeWK.self) { timeWidth = $0 }
#if os(macOS)
                .onDeleteCommand {
                    guard let selection = selection else { return }
                    vm.delete(session: selection)
                }
#endif
                .listStyle(.inset)
                .animation(.easeOut, value: vm.sessions.map(\.name))
            }
            .environmentObject(vm)
            .onAppear(perform: vm.onAppear)
        }

        var mask: some View {
            VStack(spacing: 0) {
                Color.white
                HStack(alignment: .bottom, spacing: 0) {
                    LinearGradient(gradient: .init(colors: [
                        .white, .white.opacity(0)
                    ]), startPoint: .top, endPoint: .bottom)
                    Color.white.frame(width: 10)
                }.frame(height: 25)
            }
        }
    }
}

extension HistoryScreen.SessionsList {

    struct Row: View {

        @EnvironmentObject private var vm: HistoricalSessionsVM
        private var isDownloading: Bool { vm.isDownloading[session.id] ?? false }

        let session: Session
        var dateWidth: CGFloat
        var timeWidth: CGFloat

        @State private var dateString = ""
        @State private var timeString = ""

        var body: some View {
            HStack {
                Text(session.name)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()

                Text(dateString)
                    .font(.title3)
                    .foregroundColor(.mySecondary)
                    .padding(.trailing, 15)
                    .reportMaxWidth(to: DateWK.self)
                    .frame(minWidth: dateWidth, alignment: .leading)


                Text(timeString)
                    .font(.title3)
                    .foregroundColor(.mySecondary)
                    .padding(.trailing, 15)
                    .reportMaxWidth(to: TimeWK.self)
                    .frame(minWidth: timeWidth, alignment: .leading)

                downloadButton
#if os(iOS)
                    .background(export)
#endif
            }
            .onAppear { dateString = mediumDateFormatter.string(from: session.date) }
            .onAppear { timeString = shortTimeFormatter.string(from: session.date) }
            .padding(3)
            .font(.title3)
            .contextMenu {
                Button("Rename") { vm.rename(session: session) }
                Button("Delete") { vm.delete(session: session) }
                Divider()
                Button("Download") { vm.download(session: session) }
            }
            #if os(iOS) // Some incompatibility in macOS that precludes view's display.
            .listRowBackground(exportHighlight)
            #endif
        }

        @ViewBuilder private var downloadButton: some View {
            if isDownloading {
                ProgressSpinner()

            }  else {
                Button { vm.download(session: session) } label: {
                    SFSymbol.download.image()
                        .font(.title3.weight(.medium))
                }
                .buttonStyle(HoverButtonStyle())
            }
        }
#if os(iOS)
        @ViewBuilder var export: some View {

            if vm.exportID == session.id {
                UIActivityPopover(items: [vm.export!], didDismiss: vm.didDismissExportPopover)
            }
        }
#endif

        @ViewBuilder var exportHighlight: some View {
            if vm.exportID == session.id {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.myGroupBackground)
            }
        }
    }
}

fileprivate struct DateWK: MaxWidthKey {
    public static var defaultValue: CGFloat = 50
}


fileprivate struct TimeWK: MaxWidthKey {
    public static var defaultValue: CGFloat = 50
}
