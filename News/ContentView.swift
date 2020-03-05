//
//  ContentView.swift
//  News
//
//  Created by Elnur Rzayev on 05/03/2020.
//  Copyright © 2020 Elnur Rzayev. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI
import WebKit

struct ContentView: View {
    
    @ObservedObject var list = getData()
    
    var body: some View {
        
        NavigationView{
            
            List(list.datas){ i in
                
                NavigationLink(destination:
                    
                    webView(url: i.url)
                        .navigationBarTitle("", displayMode: .inline)) {
                    HStack(spacing: 15){
                                       
                                       VStack(alignment: .leading, spacing: 10){
                                           Text(i.title).fontWeight(.heavy)
                                           Text(i.desc).lineLimit(2)
                                       }
                                       
                                       if i.image != ""{
                                           
                                           WebImage(url: URL(string: i.image), options: .highPriority, context: nil).resizable().frame(width: 110, height: 110)
                                       }
                                   }.padding(.vertical, 15)
                }
               
            }.navigationBarTitle("Headlines")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct dataType: Identifiable{
    
    var id : String
    var title : String
    var desc : String
    var url : String
    var image : String
    
}

class getData : ObservableObject{
    
    @Published var datas = [dataType]()
    
    init() {
        
        let source = "http://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=b8140e25c45043e98f82345d01f1b5c4"
        
        let url = URL(string: source)!
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: url) { (data, _, err) in
            
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            let json = try! JSON(data: data!)
            
            for i in json["articles"]{
                
                let title = i.1["title"].stringValue
                let desc = i.1["description"].stringValue
                let image = i.1["urlToImage"].stringValue
                let url = i.1["url"].stringValue
                let id = i.1["publishedAt"].stringValue
                
                DispatchQueue.main.async {
                    self.datas.append(dataType(id: id, title: title, desc: desc, url: url, image: image))
                }
            }
        }.resume()
    }
}

struct webView : UIViewRepresentable{
    
    var url : String
    func makeUIView(context: UIViewRepresentableContext<webView>) -> WKWebView {
        let view = WKWebView()
        view.load(URLRequest(url: URL(string: url)!))
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<webView>) {
        
    }
}
