import std/strutils
import nimib
import ./lib/codeOutput
var nbToc: NbBlock
var exampleCounter = 0
var figureCounter = 0
template addToc =
  newNbBlock("nbText", false, nb, nbToc, ""):
    nbToc.output = "## 目录:\n\n"
template nbNewSection(name:string) =
  let anchorName = name.toLower.replace(" ", "-")
  nbText "<a name=\"" & anchorName & "\"></a >\n<br>\n### " & name & "\n\n---"
  nbToc.output.add "1. <a href= "#" & anchorName & "\">" & name & "</a >\n"
template nbSubSection(name:string) =
  let anchorName = name.toLower.replace(" ", "-")
  nbText "<a name=\"" & anchorName & "\"></a >\n<br>\n#### " & name & "\n\n---"
  nbToc.output.add "    * <a href=\"#" & anchorName & "\">" & name & "</a >\n"
template nbExampleBlock(code: untyped) =
  inc exampleCounter
  nbText "<div style=\"background: #f8f9fa; border: 1px solid #e9ecef; border-radius: 8px; padding: 1.5em; margin: 1.5em 0;\">"
  nbText "**示例 " & $exampleCounter & "**: "
  code
  nbText "</div>"
template nbFigure(caption: string, code: untyped) =
  inc figureCounter
  nbText "<div style=\"text-align: center; margin: 2em 0;\">"
  code
  nbText "<br><em>图 " & $figureCounter & ": " & caption & "</em>"
  nbText "</div>"
template nbWarningQuote(code: untyped) =
  nbText "<blockquote style=\"border-left: 4px solid #ff6b6b; background-color: #fff5f5; padding: 1em; margin: 1em 0; border-radius: 4px;\">"
  nbText "⚠️ **警告**: "
  code
  nbText "</blockquote>"
template nbInfoQuote(code: untyped) =
  nbText "<blockquote style=\"border-left: 4px solid #4dabf7; background-color: #f0f8ff; padding: 1em; margin: 1em 0; border-radius: 4px;\">"
  nbText "ℹ️ **信息**: "
  code
  nbText "</blockquote>"
template nbTheorem(name: string, code: untyped) =
  nbText "<div style=\"background: #fff8e1; border: 1px solid #ffd54f; border-radius: 8px; padding: 1.5em; margin: 1.5em 0;\">"
  nbText "📐 **定理 - " & name & "**: "
  code
  nbText "</div>"
template nbCodeOutputFile(filename: string, code: untyped) =
  nbCode:
    code
  nbText """<details style="margin: 1em 0;">
  <summary style="cursor: pointer; color: #1976d2; font-weight: bold;">查看文件 """ & filename & """ 的完整内容</summary>
  <pre style="background: #f5f5f5; padding: 1em; border-radius: 4px; overflow-x: auto;">""" & $code & """</pre>
  </details>"""
nbInit(
  homeDir = getCurrentDir(),      // 输出到当前文件夹
  filename = "rpn_manual.html"    // 文件名
)

initCodeTheme()
nbText: """
# C++ 逆波兰计算器：从原理到实现的完整技术指南
=================================================
<br>
<div style="text-align: center; color: #666; font-style: italic;">
  一份涵盖计算机科学理论、软件工程实践与现代 C++ 编程范式的综合性文档
</div>
<br>
> "栈是计算机科学中最优雅的数据结构之一，它以其简单的 LIFO 原则解决了复杂的计算问题。"  
> —— 唐纳德·克努特，《计算机程序设计艺术》
<div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 2em; border-radius: 12px; margin: 2em 0;">
<h3 style="color: white; margin-top: 0;">📋 文档目标</h3>
<p>本技术文档旨在为读者提供逆波兰计算器实现的完整知识体系，涵盖：</p >
<ul>
<li>🎯 <strong>理论基础</strong>：逆波兰表示法的数学原理与计算模型</li>
<li>🔧 <strong>工程实践</strong>：现代 C++ 编程范式与设计模式应用</li>
<li>🛡️ <strong>健壮性设计</strong>：异常安全、错误处理与软件可靠性</li>
<li>⚡ <strong>性能优化</strong>：算法复杂度分析与代码优化策略</li>
<li>🎨 <strong>用户体验</strong>：交互式界面设计与用户友好性考量</li>
</ul>
</div>
"""
addToc()
nbNewSection "引言与背景知识"
nbText: """
## 1.1 逆波兰表示法的历史渊源
逆波兰表示法（Reverse Polish Notation, RPN）由波兰数学家 **扬·武卡谢维奇**（Jan Łukasiewicz）于1920年代提出，是数学表达范式的重要突破。其核心价值在于消除了中缀表达式中的歧义性，为计算机科学的发展奠定了理论基础。
### 1.1.1 数学表达式的演进
<div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 1em; margin: 2em 0;">
<div style="background: #f8f9fa; padding: 1em; border-radius: 8px;">
<h4>中缀表示法</h4>
<code>(3 + 4) × 5 - 6</code>
<p style="font-size: 0.9em; color: #666;">需要括号明确优先级</p >
</div>
<div style="background: #f8f9fa; padding: 1em; border-radius: 8px;">
<h4>前缀表示法</h4>
<code>- × + 3 4 5 6</code>
<p style="font-size: 0.9em; color: #666;">运算符在前，波兰表示法</p >
</div>
<div style="background: #f8f9fa; padding: 1em; border-radius: 8px;">
<h4>后缀表示法</h4>
<code>3 4 + 5 × 6 -</code>
<p style="font-size: 0.9em; color: #666;">运算符在后，逆波兰表示法</p >
</div>
</div>
"""
nbSubSection "理论基础与计算模型"
nbTheorem "逆波兰表达式的计算正确性":
  nbText: """
  对于任意合法的逆波兰表达式 <strong>E</strong>，存在唯一的计算序列使得：
  <br><br>
  <strong>计算结果 = Evaluate(E, ∅)</strong>
  <br><br>
  其中 Evaluate 函数定义如下：
  <ul>
  <li>Evaluate(数字, 栈) = 将数字压入栈</li>
  <li>Evaluate(运算符, 栈) = 弹出栈顶两个元素，执行运算，将结果压回栈</li>
  <li>Evaluate(ε, 栈) = 栈顶元素（ε 表示空表达式）</li>
  </ul>
  """
nbText: """
### 1.2.2 计算复杂度分析
对于包含 n 个标记（token）的逆波兰表达式：
| 操作类型 | 时间复杂度 | 空间复杂度 | 说明 |
|---------|-----------|-----------|------|
| 词法分析 | O(n) | O(1) | 单次遍历 |
| 栈操作 | O(n) | O(n) | 最坏情况下栈深度为 n/2 |
| 错误检测 | O(n) | O(1) | 同步进行 |
| **总体** | **O(n)** | **O(n)** | **线性复杂度** |
"""
nbNewSection "项目架构与设计理念"
nbText: """
## 2.1 软件架构概览
我们的 C++ 逆波兰计算器采用 **分层架构模式**，将系统划分为四个逻辑层次，每层负责特定的功能职责：
<div style="background: white; border: 2px solid #e9ecef; border-radius: 12px; padding: 2em; margin: 2em 0;">
<div style="display: grid; grid-template-columns: 1fr 3fr; gap: 1em; align-items: center;">
<di
"""
nbSave()
echo ">>> nbSave 已执行，准备写文件 <<<"
echo "预计路径：", getCurrentDir() / "rpn_manual.html"
