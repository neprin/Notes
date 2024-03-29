//
//  ContentView.swift
//  Notes
//
//  Created by Pavel Neprin on 10/21/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)], animation: .spring())
    var note: FetchedResults<Note>
    @State var showingAddView = false
    @State var isPinned = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List {
                    ForEach(note) { note in
                        NavigationLink(destination: EditNoteView(note: note)) {
                            VStack(alignment: .leading) {
                                Text(note.title!)
                                    .bold()
//                                Text(note.text!)
//                                    .foregroundColor(.secondary)
//                                    .lineLimit(2)
                                Text(note.date!, formatter: itemFormatter)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteNote)
                    
                    // Add pin/unpin action
                    .swipeActions(edge: .leading) {
                        Button {
                            withAnimation(.spring()) { isPinned.toggle() }
                        } label: {
                            if isPinned {
                                Label("Unpin", systemImage: "pin.slash")
                            } else {
                                Label("Pin", systemImage: "pin")
                            }
                        }
                        .tint(isPinned ? .gray : .yellow)
                    }
                }
                .listStyle(.automatic)
                .navigationTitle("Notes")
                
                //toolbar after list!
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button {
                            withAnimation(.spring() ) {
                                showingAddView.toggle()
                            }
                        } label: {
                            Label("Add Note", systemImage: "plus")
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Text("\(note.count) notes")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
            }
            
            //opening AddNoteView
            .sheet(isPresented: $showingAddView) {
                AddNoteView()
            }
        }
    }
    
    // Deletes Note at the current offset
    private func deleteNote(offsets: IndexSet) {
        withAnimation(.spring()) {
            offsets.map { note[$0] }.forEach(managedObjContext.delete)
            
            // Save changes to our database
            DataController().save(context: managedObjContext)
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
