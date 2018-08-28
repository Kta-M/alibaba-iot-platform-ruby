require "mqtt"
require "openssl"
require "json"
require "pry"

client_id      = ENV["CLIENT_ID"]
product_key    = ENV["PRODUCT_KEY"]
device_name    = ENV["DEVICE_NAME"]
device_secret  = ENV["DEVICE_SECRET"]
region         = ENV["REGION"]
binding.pry

host           = "#{product_key}.iot-as-mqtt.#{region}.aliyuncs.com"
port           = 1883

timestamp      = (Time.now.to_f*1000).to_i
mqtt_client_id = "#{client_id}|securemode=3,signmethod=hmacsha1,timestamp=#{timestamp}|"
user_name      = "#{device_name}&#{product_key}"
content        = "clientId#{client_id}deviceName#{device_name}productKey#{product_key}timestamp#{timestamp}"
password       = OpenSSL::HMAC.digest('sha1', device_secret, content).unpack("H*").first

c = MQTT::Client.connect(
  host:      host,
  port:      port,
  client_id: mqtt_client_id,
  username:  user_name,
  password:  password,
  keep_alive: 60
)

topic = "/#{product_key}/#{device_name}/data"
message = {serial_number: device_name, timestamp: timestamp, temperature: 10.0}.to_json
c.publish(topic, message, true)

c.disconnect
