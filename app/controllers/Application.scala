package controllers

import play.api._
import play.api.mvc._
import views._
import play.api.Play.current

object Application extends Controller {
  
  def index = Action {
    Ok(views.html.index("Your new application is ready."))
  }
  
  def data = Action {
    Ok(views.Data.allData)
  }
}


