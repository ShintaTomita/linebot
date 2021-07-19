
class LinebotController < ApplicationController
  require 'line/bot'
  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]
  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      return head :bad_request
    end
    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          seed1 = select_word
          message = [{
            type: 'text',
            text: "ドウシタ？"
          },{
            type: 'text',
            text: "オマエナァ、#{seed1}！！"
          }]
          client.reply_message(event['replyToken'], message)
        end
      end
    }
    head :ok
  end
  private
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
  def select_word
    # この中を変えると返ってくるキーワードが変わる
    seeds = ["今日も振り切れ", "しんどい？　人間やめるか", "最高に生きろ", "武士は食わねど高楊枝",
             "世の中、金か？", "諦めたらそこで終わり", "妬み、僻みは人生を破滅させる", "人間が最高なのは夢を実現出来る事",
             "お前の苦労話、戦争孤児に比べたらクソ", "人間のみ許された特権は笑うこと", "やるという強い意志", "深呼吸", "とにかく笑え",
             "声を大にして笑え", "常識を疑え", "大人達が作った常識に惑わされるな", "常に自分の直感を信じろ", "君は天才, 何かの",
             "日本はとっても良いお国、でも右にならえの教育はどうなんだ", "まず人を助けろ,思いっきりな", "とにかく自分が人を愛そう", "なんとかなる", "ウンコデモタベトケ"]
    seeds.sample
  end
end
