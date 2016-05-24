//
//  ViewController.swift
//  tickets
//
//  Created by Oscar Reynaldo Flores Jimenez on 20/05/16.
//  Copyright © 2016 edcatelecomunicaciones.mx. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var datos: NSMutableArray = []
    var diccionario: [String:String] = [:]
    var diccionarios = [[String:String]]()
    var id: Int = 0
    let socket = SocketIOClient(socketURL: NSURL(string: "http://10.0.6.13:4000")!, options: [.Log(false), .ForcePolling(true)])
//    let socket = SocketIOClient(socketURL: NSURL(string: "http://201.161.11.66:4000")!, options: [.Log(false), .ForcePolling(true)])
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        socket.connect()
        
        socket.on("nuevo_ticket") {data, ack in
            self.obtenerTickets()
            var ticket = [[String:String]]()
            
            for d in data {
                ticket.append(d as! [String : String])
            }
            
            let mensajeTicket: String = "\(ticket[0]["usuario"]!): \(ticket[0]["problema"]!)"
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIView.transitionWithView(self.view,
                    duration: 0.15, options: [.CurveEaseInOut, .TransitionCrossDissolve],
                    animations: { () -> Void in
                        self.notificacion("\(mensajeTicket)")
                        self.tableView.reloadData()
                    }, completion: nil)
            })
        }
        
        socket.on("atendiendo") {data, act in
            self.obtenerTickets()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
        
        socket.on("ticket_atendido_sistemas") {data, act in
            self.obtenerTickets()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
        
        obtenerTickets()
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(datos.count==0) {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomCell
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomCell
            let estado: String?;
            let prioridad: String?;
            let orden: String?;
            
            estado = diccionarios[indexPath.row]["estatus"]!
            prioridad = diccionarios[indexPath.row]["prioridad"]!
            orden = diccionarios[indexPath.row]["id"]!
            
            var imgEstado: String = ""
            var imgPrioridad: String = ""
            
            if estado == "NO ATENDIDO" {
                imgEstado = "azul"
            } else if estado == "EN PROCESO" {
                imgEstado = "amarillo"
            } else {
                imgEstado = "verde"
            }
            
            if prioridad == "BAJA" {
                imgPrioridad = "verde"
            } else if prioridad == "MEDIA" {
                imgPrioridad = "amarillo"
            } else {
                imgPrioridad = "rojo"
            }
            
            cell.estado.image = UIImage(named: "\(imgEstado)")
            cell.prioridad.image = UIImage(named: "\(imgPrioridad)")
            cell.lblEstado.text = estado
            cell.lblPrioridad.text = prioridad
            cell.orden.text = orden
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datos.count == 0 {
            return 1
        } else {
            return datos.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.notificacion("nuevo ticket")
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let next = self.storyboard?.instantiateViewControllerWithIdentifier("ticketDetallado") as! TicketDetalladoViewController
        next.idOrden = diccionarios[indexPath.row]["id"]
        
        self.navigationController?.pushViewController(next, animated: true)
        
    }
    
    //enviar notificacion
    func notificacion(texto: String) {
        let dateTime = NSDate()
        
        let dateComp = NSDateComponents()
        
        dateComp.second = 2
        
        let cal = NSCalendar.currentCalendar()
        
        let fireDate: NSDate = cal.dateByAddingComponents(dateComp, toDate: dateTime, options: NSCalendarOptions.init(rawValue: 0))!
        
        let notification: UILocalNotification = UILocalNotification()
        
        notification.alertBody = "\(texto)"
        
        notification.fireDate = fireDate
        
        notification.soundName = UILocalNotificationDefaultSoundName
        
        notification.applicationIconBadgeNumber = 0
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    //obtener orden estatus y prioridad webservices
    func obtenerTickets() {
        let semaphore = dispatch_semaphore_create(0);
//        let jsonUrl = "http://10.0.6.13/webservices/tickets/lista-tickets.php"
        let jsonUrl = "http://201.161.11.66/webservices/tickets/lista-tickets.php"
        let session = NSURLSession.sharedSession()
        let shotsUrl = NSURL(string: jsonUrl)
        let task = session.dataTaskWithURL(shotsUrl!) {
            (data, response, error) -> Void in
            if error != nil {
                print("ERROR")
                dispatch_semaphore_signal(semaphore);
            } else {
                do {
                    self.datos = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers ) as! NSMutableArray
                    dispatch_semaphore_signal(semaphore);
                } catch _ {
                    print("error")
                    dispatch_semaphore_signal(semaphore);
                }
                dispatch_semaphore_signal(semaphore);
            }
        }
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        obtenerDiccionario()
    }
    
    //pasar a un array de diccionarios
    func obtenerDiccionario() {
        diccionarios.removeAll()
        for arreglo in datos {
            let a = arreglo as! [NSObject:AnyObject]
            diccionario = ["estatus":"\(a["estatus"]!)", "id": "\(a["id"]!)", "prioridad":"\(a["prioridad"]!)"]
            diccionarios.append(diccionario)
        }
    }
    
}

