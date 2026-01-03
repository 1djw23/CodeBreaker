import SwiftUI

enum CodeColor: CaseIterable {
    case red, green, blue, yellow

    var color: Color {
        switch self {
        case .red: return .red
        case .green: return .green
        case .blue: return .blue
        case .yellow: return .yellow
        }
    }
}

struct Guess {
    var colors: [CodeColor]
    var black: Int
    var white: Int
}

struct ContentView: View {

    @State private var secret: [CodeColor] = []
    @State private var currentGuess: [CodeColor] = []
    @State private var guesses: [Guess] = []
    @State private var gameOver = false
    @State private var win = false

    let maxTurns = 12

    var body: some View {
        VStack(spacing: 16) {
            Text("Color Code")
                .font(.largeTitle)
                .bold()

            // 历史猜测
            List(guesses.indices, id: \.self) { index in
                HStack {
                    ForEach(guesses[index].colors.indices, id: \.self) { i in
                        Circle()
                            .fill(guesses[index].colors[i].color)
                            .frame(width: 20, height: 20)
                    }

                    Spacer()

                    Text("⚫ \(guesses[index].black)")
                    Text("⚪ \(guesses[index].white)")
                }
            }
            .frame(height: 300)

            // 当前选择
            HStack {
                ForEach(currentGuess.indices, id: \.self) { i in
                    Circle()
                        .fill(currentGuess[i].color)
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            cycleColor(at: i)
                        }
                }
            }

            Button("提交") {
                submitGuess()
            }
            .disabled(gameOver)

            if gameOver {
                Text(win ? "🎉 你赢了！" : "💥 游戏失败")
                    .font(.title2)
            }
        }
        .padding()
        .onAppear {
            startGame()
        }
    }

    // MARK: - 游戏逻辑

    func startGame() {
        secret = (0..<4).map { _ in CodeColor.allCases.randomElement()! }
        currentGuess = Array(repeating: .red, count: 4)
        guesses.removeAll()
        gameOver = false
        win = false
    }

    func cycleColor(at index: Int) {
        let all = CodeColor.allCases
        let current = currentGuess[index]
        let nextIndex = (all.firstIndex(of: current)! + 1) % all.count
        currentGuess[index] = all[nextIndex]
    }

    func submitGuess() {
        let feedback = evaluate(secret: secret, guess: currentGuess)
        guesses.append(
            Guess(colors: currentGuess,
                  black: feedback.black,
                  white: feedback.white)
        )

        if feedback.black == 4 {
            win = true
            gameOver = true
        } else if guesses.count >= maxTurns {
            gameOver = true
        }
    }

    func evaluate(secret: [CodeColor], guess: [CodeColor]) -> (black: Int, white: Int) {
        var black = 0
        var secretLeft: [CodeColor] = []
        var guessLeft: [CodeColor] = []

        for i in 0..<4 {
            if secret[i] == guess[i] {
                black += 1
            } else {
                secretLeft.append(secret[i])
                guessLeft.append(guess[i])
            }
        }

        var white = 0
        for color in guessLeft {
            if let index = secretLeft.firstIndex(of: color) {
                white += 1
                secretLeft.remove(at: index)
            }
        }

        return (black, white)
    }
}
