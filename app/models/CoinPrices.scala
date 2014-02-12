package models
import play.api.db.DB
import org.joda.time.DateTime
import anorm._
import anorm.SqlParser._
import play.api.Play.current

case class CoinPrice(
  recordedAt: DateTime,
  btc: Double,
  mcx: Double,
  msc: Double,
  btb: Double,
  ltc: Double,
  uno: Double,
  pts: Double,
  nvc: Double,
  btg: Double)

object CoinPrices {

  private val cParser = long("id") ~ date("recorded_at") ~ get[Double]("btc") ~ get[Double]("mcx") ~ get[Double]("msc") ~
		  get[Double]("btb") ~ get[Double]("ltc") ~ get[Double]("uno") ~ get[Double]("pts") ~ get[Double]("nvc") ~
		  get[Double]("btg") map {
    case id ~ recorded_at ~ btc ~ mcx ~ msc ~ btb ~ ltc ~ uno ~ pts ~ nvc ~ btg => 
      CoinPrice(new DateTime(recorded_at), btc, mcx, msc, btb, ltc, uno, pts, nvc, btg)
  }
 
  def insert(cp: CoinPrice) = DB.withConnection { implicit c =>
    SQL("insert into coin_prices (recorded_at, btc, mcx, msc, btb, ltc, uno, pts, nvc, btg) values({recorded_at}, {btc}, {mcx}, {msc}, {btb}, {ltc}, {uno}, {pts}, {nvc}, {btg})")
      .on(
        'recorded_at -> cp.recordedAt.toDate,
        'btc -> cp.btc,
        'mcx -> cp.mcx,
        'msc -> cp.msc,
        'btb -> cp.btb,
        'ltc -> cp.ltc,
        'uno -> cp.uno,
        'pts -> cp.pts,
        'nvc -> cp.nvc,
        'btg -> cp.btg)
      .execute()
  }
  
  def all = DB.withConnection { implicit c =>
    SQL("select * from coin_prices").as(cParser *)
  }
}