import QtQuick

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Pong Game")

    Rectangle {
        id: gameArea
        anchors.fill: parent
        color: "black"
        focus: true

        property int leftScore : 0
        property int rightScore : 0
        property bool isStarted : false

        // Left score
        Text {
            id: leftScoreText
            font.pointSize: 20
            color: "white"
            x: parent.width / 4 - 10
            y: 20
            text: gameArea.leftScore
            visible: true
        }

        // Right score
        Text {
            id: rightScoreText
            font.pointSize: 20
            color: "white"
            x: 3 * (parent.width / 4) - 10
            y: 20
            text: gameArea.rightScore
            visible: true
        }

        // Notificator
        Text {
            id: notificator
            font.pointSize: 30
            color: "white"
            anchors.centerIn: parent
            text: "Press Space To Start"
            visible: true
        }

        // Left paddle
        Rectangle {
            id: leftPaddle
            width: 10
            height: 60
            color: "white"
            x: 20
            y: parent.height / 2 - height / 2

            property bool moveUp: false
            property bool moveDown: false
        }

        // Right paddle - simple bot
        Rectangle {
            id: rightPaddle
            width: 10
            height: 60
            color: "white"
            x: parent.width - width - 20
            y: parent.height / 2 - height / 2
        }

        // Ball
        Rectangle {
            id: ball
            width: 10
            height: 10
            radius: 10
            color: "white"
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height / 2
            visible: false

            property real xVelocity: 5
            property real yVelocity: 5
            property bool paused: false

            function resetBall() {
                ball.x = gameArea.width / 2 - ball.width / 2
                ball.y = gameArea.height / 2 - ball.height / 2
                ball.xVelocity = 5 * (Math.random() > 0.5 ? 1 : -1)
                ball.yVelocity = 5 * (Math.random() > 0.5 ? 1 : -1)
                paused = true
                delayTimer.start()
            }
        }

        Timer {
            id: gameLoop
            interval: 16  // ~60 FPS
            running: false
            repeat: true
            onTriggered: {
                if (!ball.paused)
                {
                    // Move the ball
                    ball.x += ball.xVelocity
                    ball.y += ball.yVelocity

                    // Ball collision with top and bottom walls
                    if (ball.y <= 0 || ball.y + ball.height >= gameArea.height) {
                        ball.yVelocity *= -1
                    }

                    // Ball collision with paddles
                    if ((ball.x <= leftPaddle.x + leftPaddle.width && ball.y + ball.height >= leftPaddle.y && ball.y <= leftPaddle.y + leftPaddle.height) ||
                            (ball.x + ball.width >= rightPaddle.x && ball.y + ball.height >= rightPaddle.y && ball.y <= rightPaddle.y + rightPaddle.height)) {
                        ball.xVelocity *= -1.1  // Increase speed slightly
                    }

                    // Ball out of bounds
                    if (ball.x + ball.width < 0) {
                        gameArea.rightScore++
                        ball.resetBall()
                    }
                    else if ( ball.x > gameArea.width) {
                        gameArea.leftScore++
                        ball.resetBall()
                    }

                    // Check win condition
                    if (gameArea.leftScore >= 3) {
                        gameLoop.stop()
                        ball.visible = false
                        notificator.text = "Left Paddle WIN\nPress Space To Start"
                        notificator.visible = true
                        gameArea.isStarted = false
                    }
                    else if (gameArea.rightScore >= 3) {
                        gameLoop.stop()
                        ball.visible = false
                        notificator.text = "Right Paddle WIN\nPress Space To Start"
                        notificator.visible = true
                        gameArea.isStarted = false
                    }
                }

                // Move left paddle
                if (leftPaddle.moveUp && leftPaddle.y > 0) {
                    leftPaddle.y -= 5
                }
                if (leftPaddle.moveDown && leftPaddle.y < gameArea.height - leftPaddle.height) {
                    leftPaddle.y += 5
                }

                // Simple bot for right paddle
                if (rightPaddle.y + rightPaddle.height / 2 < ball.y && rightPaddle.y + rightPaddle.height < gameArea.height) {
                    rightPaddle.y += 2
                } else if (rightPaddle.y + rightPaddle.height / 2 > ball.y && rightPaddle.y > 0) {
                    rightPaddle.y -= 2
                }
            }
        }

        Timer {
            id: delayTimer
            interval: 2000  // 2 seconds delay
            running: false
            repeat: false
            onTriggered: {
                ball.paused = false // resume ball moving
            }
        }

        Keys.onPressed: (event) => {
                            // right pad
                            if (event.key === Qt.Key_Up) {
                                leftPaddle.moveUp = true
                            }
                            if (event.key === Qt.Key_Down) {
                                leftPaddle.moveDown = true
                            }

                            if (!isStarted && event.key === Qt.Key_Space) {
                                gameArea.leftScore = 0
                                gameArea.rightScore = 0
                                notificator.text = ""
                                notificator.visible = false
                                ball.visible = true
                                gameArea.isStarted = true
                                gameLoop.start()
                            }
                        }

        Keys.onReleased: (event) => {
                             // left pad
                             if (event.key === Qt.Key_Up) {
                                 leftPaddle.moveUp = false
                             }
                             if (event.key === Qt.Key_Down) {
                                 leftPaddle.moveDown = false
                             }
                         }
    }
}
