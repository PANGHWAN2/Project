<!doctype html>
<html lang="en">
<head>
    <title>Websocket ChatRoom</title>


    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/meyer-reset/2.0/reset.min.css"/>
    <script src="https://code.jquery.com/jquery-1.8.3.min.js"
            integrity="sha256-YcbK69I5IXQftf/mYD8WY0/KmEDCv1asggHpJk1trM8=" crossorigin="anonymous"></script>

    <style>
        .chat_wrap {
            border: 1px solid #999;
            width: 300px;
            padding: 5px;
            font-size: 13px;
            color: #333;


        }

        .chat_wrap .inner {
            background-color: #acc2d2;
            border-radius: 5px;
            padding: 10px;
            overflow-y: scroll;
            height: 400px;

        }
        .chat_wrap .inner ul.list-group{
            transform: rotate(180deg);
        }
        .chat_wrap .inner ul.list-group li.list-group-item{
            transform: rotate(-180deg);
        }


        .chat_wrap .item {
            margin-top: 15px
        }

        .chat_wrap .item:first-child {
            margin-top: 0px
        }

        .chat_wrap .item .box {
            display: inline-block;
            max-width: 180px;
            position: relative
        }

        .chat_wrap .item .box::before {
            content: "";
            position: absolute;
            left: -8px;
            top: 9px;
            border-top: 0px solid transparent;
            border-bottom: 8px solid transparent;
            border-right: 8px solid #fff;
        }

        .chat_wrap .item .box .msg {
            background: #fff;
            border-radius: 10px;
            padding: 8px;
            text-align: left
        }

        .chat_wrap .item .box .time {
            font-size: 11px;
            color: #999;
            position: absolute;
            right: -75px;
            bottom: 5px;
            width: 70px
        }

        .chat_wrap .item.mymsg {
            text-align: right
        }

        .chat_wrap .item.mymsg .box::before {
            left: auto;
            right: -8px;
            border-left: 8px solid #fee600;
            border-right: 0;
        }

        .chat_wrap .item.mymsg .box .msg {
            background: #fee600
        }

        .chat_wrap .item.mymsg .box .time {
            right: auto;
            left: -75px
        }

        .chat_wrap .item .box {
            transition: all .3s ease-out;
            margin: 0 0 0 20px;
            opacity: 0
        }

        .chat_wrap .item.mymsg .box {
            transition: all .3s ease-out;
            margin: 0 20px 0 0;
        }

        .chat_wrap .item.on .box {
            margin: 0;
            opacity: 1;
        }

        input[type="text"] {
            border: 0;
            width: 100%;
            background: #ddd;
            border-radius: 5px;
            height: 30px;
            padding-left: 5px;
            box-sizing: border-box;
            margin-top: 5px
        }

        input[type="text"]::placeholder {
            color: #999
        }




    </style>

    <script>
        // $(function () {
        //     $("input[type='text']").keypress(function (e) {
        //         if (e.keyCode == 13 && $(this).val().length) {
        //             var _val = $(this).val();
        //             var _class = $(this).attr("class");
        //             $(this).val('');
        //             var _tar = $(".chat_wrap .inner").append('<div class="item ' + _class + '"><div class="box"><p class="msg">' + _val + '</p><span class="time">' + currentTime() + '</span></div></div>');
        //
        //             var lastItem = $(".chat_wrap .inner").find(".item:last");
        //             setTimeout(function () {
        //                 lastItem.addClass("on");
        //             }, 10);
        //
        //             var position = lastItem.position().top + $(".chat_wrap .inner").scrollTop();
        //             console.log(position);
        //
        //             $(".chat_wrap .inner").stop().animate({scrollTop: position}, 500);
        //         }
        //     });
        //
        // });

        var currentTime = function () {
            var date = new Date();
            var hh = date.getHours();
            var mm = date.getMinutes();
            var apm = hh > 12 ? "오후" : "오전";
            var ct = apm + " " + hh + ":" + mm + "";
            return ct;
        }

    </script>


    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">

    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="/webjars/bootstrap/4.3.1/dist/css/bootstrap.min.css">
    <style>
        [v-cloak] {
            display: none;
        }
    </style>
</head>
<body>
<div class="container" id="app" v-cloak>
    <div class="row">
        <div class="col-md-6">
            <h4>{{roomName}} <span class="badge badge-info badge-pill">{{userCount}}</span></h4>
        </div>
        <div class="col-md-6 text-right">
            <a class="btn btn-primary btn-sm" href="/logout">로그아웃</a>
            <a class="btn btn-info btn-sm" href="/chat/room">채팅방 나가기</a>
        </div>
    </div>


    <div class="chat_wrap">
        <div class="inner">



            <ul class="list-group">
                <li class="list-group-item" v-for="message in messages">
                    {{message.sender}} : {{message.message}}</a>
                </li>
            </ul>



        </div>
    </div>
    <div class="input-group">
        <div class="input-group-prepend">
            <label class="input-group-text">내용</label>
        </div>
        <input type="text" class="form-control" v-model="message" v-on:keypress.enter="sendMessage('TALK')">
        <div class="input-group-append">
            <button class="btn btn-primary" type="button" @click="sendMessage('TALK')">보내기</button>
        </div>
    </div>

    <!-- JavaScript -->
    <script src="/webjars/vue/2.5.16/dist/vue.min.js"></script>
    <script src="/webjars/axios/0.17.1/dist/axios.min.js"></script>
    <script src="/webjars/sockjs-client/1.1.2/sockjs.min.js"></script>
    <script src="/webjars/stomp-websocket/2.3.3-1/stomp.min.js"></script>
    <script>


        // websocket & stomp initialize
        var sock = new SockJS("/ws-stomp");
        var ws = Stomp.over(sock);
        // vue.js
        var vm = new Vue({
            el: '#app',
            data: {
                roomId: '',
                roomName: '',
                message: '',
                messages: [],
                token: '',
                userCount: 0
            },
            created() {
                this.roomId = localStorage.getItem('wschat.roomId');
                this.roomName = localStorage.getItem('wschat.roomName');
                var _this = this;
                axios.get('/chat/user').then(response => {
                    _this.token = response.data.token;
                    ws.connect({"token": _this.token}, function (frame) {
                        ws.subscribe("/sub/chat/room/" + _this.roomId, function (message) {
                            var recv = JSON.parse(message.body);
                            _this.recvMessage(recv);
                        });
                    }, function (error) {
                        alert("서버 연결에 실패 하였습니다. 다시 접속해 주십시요.");
                        location.href = "/chat/room";
                    });
                });
            },
            methods: {
                sendMessage: function (type) {
                    ws.send("/pub/chat/message", {"token": this.token}, JSON.stringify({
                        type: type,
                        roomId: this.roomId,
                        message: this.message
                    }));
                    this.message = '';
                },
                recvMessage: function (recv) {
                    this.userCount = recv.userCount;
                    this.messages.unshift({"type": recv.type, "sender": recv.sender, "message": recv.message})
                }
            }
        });
    </script>


    <#--<div class="chat_wrap">-->
    <#--    <div class="inner">-->

    <#--        <!-- <div class="item">-->
    <#--            <div class="box">-->
    <#--                <p class="msg">안녕하세요</p>-->
    <#--                <span class="time">오전 10:05</span>-->
    <#--            </div>-->
    <#--        </div>-->

    <#--        <div class="item mymsg">-->
    <#--            <div class="box">-->
    <#--                <p class="msg">안녕하세요</p>-->
    <#--                <span class="time">오전 10:05</span>-->
    <#--            </div>-->
    <#--        </div> &ndash;&gt;-->

    <#--    </div>-->

    <#--    <input type="text" class="mymsg" placeholder="내용 입력">-->
    <#--    &lt;#&ndash;        <input type="text" class="yourmsg" placeholder="내용 입력">&ndash;&gt;-->
    <#--</div>-->


</body>
</html>