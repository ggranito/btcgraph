import tasks.FetchPrices
import play.api.libs.concurrent.Akka
import play.api._
import play.api.Play.current
import scala.concurrent.duration._
import play.api.libs.concurrent.Execution.Implicits._

object Global extends play.api.GlobalSettings {

  override def onStart(app: play.api.Application) {
    Akka.system.scheduler.schedule(0.microsecond, 5.minute) {
	  FetchPrices.fetchPrices
	}  
  }

}