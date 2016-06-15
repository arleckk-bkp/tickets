//
//  TicketDetalladoViewController.swift
//  tickets
//
//  Created by Oscar Reynaldo Flores Jimenez on 20/05/16.
//  Copyright © 2016 edcatelecomunicaciones.mx. All rights reserved.
//

import UIKit

class TicketDetalladoViewController: UIViewController {

    var idOrden: String?
    var ticket: NSDictionary = [:]
//    let socket = SocketIOClient(socketURL: NSURL(string: "http://10.0.6.13:4000")!, options: [.Log(true), .ForcePolling(true)])
    let socket = SocketIOClient(socketURL: NSURL(string: "http://201.161.11.66:4000")!, options: [.Log(true), .ForcePolling(true)])
    
    @IBOutlet weak var prioridad: UILabel!
    @IBOutlet weak var imagenPrioridad: UIImageView!
    @IBOutlet weak var estatus: UILabel!
    @IBOutlet weak var imagenEstatus: UIImageView!
    @IBOutlet weak var tipo: UILabel!
    @IBOutlet weak var subtipo: UILabel!
    @IBOutlet weak var usuario: UILabel!
    @IBOutlet weak var validador: UILabel!
    @IBOutlet weak var comentarioTicket: UITextView!
    @IBOutlet weak var comentarioSistemas: UITextView!
    @IBOutlet weak var btnAtender: UIButton!
    @IBOutlet weak var btnFinalizar: UIButton!
    
    func obtenerTicket(id: String) -> NSDictionary{
        let semaphore = dispatch_semaphore_create(0)
//        let jsonURL = "http://10.0.6.13/webservices/tickets/obtener-detalles-ticket.php?id=\(id)"
        let jsonURL = "http://201.161.11.66/webservices/tickets/obtener-detalles-ticket.php?id=\(id)"
        let session = NSURLSession.sharedSession()
        let shorURL = NSURL(string: jsonURL)
        var jsonData: NSDictionary = [:]
        let task = session.dataTaskWithURL(shorURL!) {
            (data,response,error) -> Void in
            if error != nil {
                print("ERROR")
                dispatch_semaphore_signal(semaphore)
            } else {
                do {
                    jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    dispatch_semaphore_signal(semaphore)
                } catch _ {
                    print("error")
                    dispatch_semaphore_signal(semaphore)
                }
            }
        }
        task.resume()
        dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER)
        return jsonData
    }
    
    func atenderTicket(id: String)-> String {
        let semaphore = dispatch_semaphore_create(0)
//        let jsonURL = "http://10.0.6.13/webservices/tickets/atender.php?id=\(id)"
        let jsonURL = "http://201.161.11.66/webservices/tickets/atender.php?id=\(id)"
        let session = NSURLSession.sharedSession()
        let shorURL = NSURL(string: jsonURL)
        var msg: String = ""
        let task = session.dataTaskWithURL(shorURL!) {
            (data,response,error) -> Void in
            if error != nil {
                print("ERROR")
                dispatch_semaphore_signal(semaphore)
            } else {
                do {
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    msg = String(jsonData["msg"]!)
                    dispatch_semaphore_signal(semaphore)
                } catch _ {
                    print("error")
                    dispatch_semaphore_signal(semaphore)
                }
            }
        }
        task.resume()
        dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER)
        return msg
    }
    
    func finalizarTicket(id: String, solucion: String) -> String {
        let semaphore = dispatch_semaphore_create(0)
//        let jsonURL = "http://10.0.6.13/webservices/tickets/finalizar.php"
        let jsonURL = "http://201.161.11.66/webservices/tickets/finalizar.php"
        let session = NSURLSession.sharedSession()
        let shorURL = NSURL(string: jsonURL)
        let request = NSMutableURLRequest(URL: shorURL!)
        request.HTTPMethod = "POST"
        
        let idParam = "id=\(id)&solucion=\(solucion)"
    
        request.HTTPBody = idParam.dataUsingEncoding(NSUTF8StringEncoding)
        
        var msg: String = ""
        let task = session.dataTaskWithRequest(request) {
            (data,response,error) -> Void in
            if error != nil {
                print("ERROR")
                dispatch_semaphore_signal(semaphore)
            } else {
                do {
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    msg = String(jsonData["msg"]!)
                    print(msg)
                    dispatch_semaphore_signal(semaphore)
                } catch _ {
                    print("error")
                    dispatch_semaphore_signal(semaphore)
                }
            }
        }
        task.resume()
        dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER)
        return msg
    }
    
    func cambiarEstado() {
        print("se atendio el estado")
        
    }
    
    
    @IBAction func btnAtenderPressed(sender: UIButton) {
        let atender: String?
        atender = atenderTicket(idOrden!)
        print(atender!)
        if atender! == "success" {
            let datos = [
                "estado":"EN PROCESO",
                "id":"\(idOrden)"
            ]
            socket.emit("atendiendo", datos)
            btnAtender.enabled = false
            btnFinalizar.enabled = true
            imagenEstatus.image = UIImage(named: "amarillo")
            
        } else {
            print("ocurrio un error en atender")
        }
    }
    
    @IBAction func btnFinalizarPressed(sender: UIButton) {
        let finalizar: String?
        let solucion: String? = comentarioSistemas.text
        finalizar = finalizarTicket(idOrden!, solucion: solucion!)
        
        if finalizar! == "success" {
//            cambiarEstado()
            let usuario = ticket["usuario"]!
            socket.emit("ticket_atendido", usuario)
            btnFinalizar.enabled = false
            imagenEstatus.image = UIImage(named: "verde")
        } else {
            print("ocurrio un error en atender")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(animated: Bool) {
        
        if Reachability.isConnectedToNetwork() == true {
            socket.connect()
            
            ticket = obtenerTicket(idOrden!)
            
            //imagenes
            var imgEstado: String = ""
            var imgPrioridad: String = ""
            
            if String(ticket["estatus"]!) == "NO ATENDIDO" {
                imgEstado = "azul"
                btnAtender.enabled = true
                btnFinalizar.enabled = false
            } else if String(ticket["estatus"]!) == "EN PROCESO" {
                imgEstado = "amarillo"
                btnAtender.enabled = false
                btnFinalizar.enabled = true
            } else {
                imgEstado = "verde"
                btnAtender.enabled = false
                btnFinalizar.enabled = false
            }
            
            if String(ticket["prioridad"]!) == "BAJA" {
                imgPrioridad = "verde"
            } else if String(ticket["prioridad"]!) == "MEDIA" {
                imgPrioridad = "amarillo"
            } else {
                imgPrioridad = "rojo"
            }
            
            imagenEstatus.image = UIImage(named: imgEstado)
            imagenPrioridad.image = UIImage(named: imgPrioridad)
            
            estatus.text = String(ticket["estatus"]!)
            prioridad.text = String(ticket["prioridad"]!)
            tipo.text = "TIPO: \(String(ticket["tipo"]!))"
            subtipo.text = "SUBTIPO: \(String(ticket["subtipo"]!))"
            usuario.text = "USUARIO: \(String(ticket["usuario"]!))"
            validador.text = "VALIDADOR: \(String(ticket["validador"]!))"
            comentarioTicket.text = String(ticket["comentario"]!)
            comentarioSistemas.text = String(ticket["solucion"]!)
            
//            print("El id enviado es: \(idOrden!)")
        } else {
//            print("Internet connection FAILED")
            let alert = UIAlertController(title: "No Internet Connection", message: "Ahorita no joven, cuando tenga Internet me avisa", preferredStyle: UIAlertControllerStyle.Alert)
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action) in NSLog("No Internet Connection")})
            alert.addAction(OKAction)
            self.presentViewController(alert, animated: true, completion: {})
        }
        
        super.viewWillAppear(animated)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
