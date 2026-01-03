import SwiftUI

// 四种颜色
enum CodeColor: CaseIterable {
    case red, green, blue, yellow

    // 返回 SwiftUI Color
    func color() -> Color {
        switch self {
        case .red: return .red
        case .green: return .green
        case .blue: return .blue
        case .yellow: return .yellow
        }
    }
}

// 每次猜测的记录
struct Guess {
    var colors: [CodeColor]
    var black: Int // 位置和颜色都对
    var white: Int // 颜色对但位置错
}

struct ContentView: View {
    // MARK: - 游戏状态
    @State private var secret: [CodeColor] = []
    @State private var guess: [CodeColor] = [.red, .red, .red, .red] // 当前猜测
    @State private var allGuesses: [Guess] = []
    @State private var message = "开始游戏，选择颜色猜密码！"

    // MARK: - UI
    var body: some View {
        VStack {
            Text("Color Code")
                .font(.largeTitle)
                .padding()

            Text(message)
                .padding()

            // 历史猜测列表
            List(allGuesses.indices, id: \.self) { i in
                HStack {
                    // 显示猜测的颜色
                    ForEach(0..<4, id: \.self) { j in
                        Circle()
                            .fill(allGuesses[i].colors[j].color())
                            .frame(width: 30, height: 30)
                    }

                    Spacer()

                    // 黑白点
                    HStack(spacing: 5) {
                        // 黑点
                        ForEach(0..<allGuesses[i].black, id: \.self) { _ in
                            Circle()
                                .fill(Color.black)
                                .frame(width: 20, height: 20)
                        }
                        // 白点
                        ForEach(0..<allGuesses[i].white, id: \.self) { _ in
                            Circle()
                                .fill(Color.white)
                                .overlay(Circle().stroke(Color.black))
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }

            // 当前猜测圆圈
            HStack {
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(guess[i].color())
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            cycleColor(at: i) // 点击切换颜色
                        }
                }
            }
            .padding()

            Button("提交") {
                submitGuess()
            }
            .padding()
        }
        .onAppear(perform: startGame)
    }

    // MARK: - 游戏逻辑

    // 初始化游戏
    func startGame() {
        secret = []
        allGuesses = []
        message = "开始游戏，选择颜色猜密码！"

        // 随机生成4个颜色密码
        for _ in 0..<4 {
            secret.append(CodeColor.allCases.randomElement()!)
        }

        guess = [.red, .red, .red, .red] // 当前猜测初始为红色
    }

    // 点击圆圈切换颜色
    func cycleColor(at index: Int) {
        let colors = CodeColor.allCases
        if let currentIndex = colors.firstIndex(of: guess[index]) {
            let nextIndex = (currentIndex + 1) % colors.count
            guess[index] = colors[nextIndex]
        }
    }

    // 提交当前猜测
    func submitGuess() {
        let result = checkGuess(secret: secret, guess: guess)
        let newGuess = Guess(colors: guess, black: result.black, white: result.white)
        allGuesses.append(newGuess)

        if result.black == 4 {
            message = "🎉 恭喜！你猜对了！"
        } else if allGuesses.count >= 12 {
            message = "游戏结束！正确答案是：\(secret.map { $0.color().description })"
        } else {
            message = "继续猜！"
        }
    }

    // 计算黑点和白点（初学者简单方法）
    func checkGuess(secret: [CodeColor], guess: [CodeColor]) -> (black: Int, white: Int) {
        var black = 0
        var white = 0

        var secretCopy = secret
        var guessCopy = guess

        // 先算黑点
        for i in 0..<4 {
            if guessCopy[i] == secretCopy[i] {
                black += 1
                // 标记已检查
                guessCopy[i] = .red
                secretCopy[i] = .green
            }
        }

        // 再算白点
        for i in 0..<4 {
            for j in 0..<4 {
                if guessCopy[i] == secretCopy[j] && guessCopy[i] != .red && secretCopy[j] != .green {
                    white += 1
                    secretCopy[j] = .green
                    break
                }
            }
        }

        return (black, white)
    }
}

