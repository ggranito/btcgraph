package tasks

import play.api.libs.ws.WS
import scala.concurrent._
import play.api.libs.concurrent.Execution.Implicits._
import play.api.libs.json.JsValue
import models._
import org.joda.time.DateTime
import play.api.Logger

object FetchPrices {

  def fetchPrices = {
    fetchBTCInUSD.map { btcOpt =>
       btcOpt match {
        case Some(btcInUSD) =>
          WS.url("http://www.cryptocoincharts.info/v2/api/listCoins").get().map { r =>
            val pMap = (r.json.as[Seq[JsValue]].map { coin =>
              ((coin \ "id").as[String] -> ((coin \ "price_btc").as[String].toDouble * btcInUSD))
            }).toMap
            (pMap.get("btc"), pMap.get("mcx"), pMap.get("msc"),
              pMap.get("btb"), pMap.get("ltc"), pMap.get("uno"),
              pMap.get("pts"), pMap.get("nvc"), pMap.get("btg")) match {
                case (Some(btc), Some(mcx), Some(msc), Some(btb),
                  Some(ltc), Some(uno), Some(pts), Some(nvc), Some(btg)) =>
                  CoinPrices.insert(CoinPrice(new DateTime, btc, mcx, msc, btb, ltc, uno, pts, nvc, btg))
                case _ => Logger.error("Not all prices specified")
              }
          }
        case None => Logger.error("No BTC to USD price specified")
      }
    }
  }

  def fetchBTCInUSD = {
    WS.url("https://bitpay.com/api/rates").get().map { resp =>
      resp.json.as[Seq[JsValue]].find { c =>
        (c \ "code").as[String].equals("USD")
      }.map(a => (a \ "rate").as[Double])
    }
  }
}