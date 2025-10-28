#include <iostream>
#include <stack>
#include <sstream>
#include <stdexcept>
#include <cctype>
#include <vector>
#include <string>

class RPNCalculator {
private:
    std::stack<double> st;

public:
    void clear() {
        while (!st.empty()) st.pop();
    }

    bool empty() const { return st.empty(); }

    double top() const {
        if (empty()) throw std::runtime_error("栈空");
        return st.top();
    }

    void push(double v) { st.push(v); }

    double pop() {
        double v = top();
        st.pop();
        return v;
    }

    void calculate(const std::string& op) {
        if (op == "+" || op == "-" || op == "*" || op == "/") {
            if (st.size() < 2) throw std::runtime_error("操作数不足");
            double b = pop();
            double a = pop();
            if (op == "+") { push(a + b); return; }
            if (op == "-") { push(a - b); return; }
            if (op == "*") { push(a * b); return; }
            if (op == "/") {
                if (b == 0) throw std::runtime_error("除零错误");
                push(a / b);
                return;
            }
        }
        throw std::runtime_error("未知操作符");
    }

    void printStack() const {
        if (empty()) { std::cout << "栈: (空)\n"; return; }
        std::stack<double> tmp = st;
        std::vector<double> rev;
        while (!tmp.empty()) { rev.push_back(tmp.top()); tmp.pop(); }
        std::cout << "栈: ";
        for (auto it = rev.rbegin(); it != rev.rend(); ++it)
            std::cout << *it << " ";
        std::cout << "\n";
    }
};

int main() {
    RPNCalculator calc;
    std::string line;
    std::cout << "C++ RPN 计算器\n输入表达式 (例: '5 5 +'), 或 'q' 退出.\n";
    while (true) {
        std::cout << "> ";
        if (!std::getline(std::cin, line) || line == "q") break;
        if (line.empty()) continue;
        std::istringstream iss(line);
        std::string tok;
        try {
            while (iss >> tok) {
                if (tok == "+" || tok == "-" || tok == "*" || tok == "/") {
                    calc.calculate(tok);
                } else if (tok == "clear") {
                    calc.clear();
                } else if (tok == "stk") {
                    calc.printStack();
                } else {
                    /* 尝试解析数字 */
                    size_t idx = 0;
                    double val = std::stod(tok, &idx);
                    if (idx != tok.size()) throw std::runtime_error("格式错误");
                    calc.push(val);
                }
            }
            std::cout << "结果: " << calc.top() << "\n";
            calc.clear();          // 每次表达式结束后清栈，方便下次输入
        } catch (const std::exception& e) {
            std::cerr << "错误: " << e.what() << "\n";
            calc.clear();
        }
    }
    return 0;
}

