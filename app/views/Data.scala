package views

import play.api.libs.json._
import models._

object Data {
  def allData = {
    Json.toJson(
      CoinPrices.all.toSeq.map { cp =>
        Json.toJson(
          Map(
            "time" -> Json.toJson(cp.recordedAt),
            "btc" -> Json.toJson(cp.btc),
            "mcx" -> Json.toJson(cp.mcx),
            "msc" -> Json.toJson(cp.msc),
            "btb" -> Json.toJson(cp.btb),
            "ltc" -> Json.toJson(cp.ltc),
            "uno" -> Json.toJson(cp.uno),
            "pts" -> Json.toJson(cp.pts),
            "nvc" -> Json.toJson(cp.nvc),
            "btg" -> Json.toJson(cp.btg)
          )
        )
      }
    )
  }
}