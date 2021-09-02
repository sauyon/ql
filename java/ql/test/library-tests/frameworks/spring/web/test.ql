/**
 * @kind path-problem
 */

import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.TaintTracking
import TestUtilities.InlineExpectationsTest
import DataFlow::PartialPathGraph

class ValueFlowConf extends DataFlow::Configuration {
  ValueFlowConf() { this = "qltest:valueFlowConf" }

  override predicate isSource(DataFlow::Node n) {
    n.asExpr().(MethodAccess).getMethod().hasName("source")
  }

  override predicate isSink(DataFlow::Node n) {
    n.asExpr().(Argument).getCall().getCallee().hasName("sink")
  }

  override int fieldFlowBranchLimit() { result = 50 }

  override int explorationLimit() { result = 100 }
}

class TaintFlowConf extends TaintTracking::Configuration {
  TaintFlowConf() { this = "qltest:taintFlowConf" }

  override predicate isSource(DataFlow::Node n) {
    n.asExpr().(MethodAccess).getMethod().hasName("source")
  }

  override predicate isSink(DataFlow::Node n) {
    n.asExpr().(Argument).getCall().getCallee().hasName("sink")
  }

  override int fieldFlowBranchLimit() { result = 30 }
}

class HasFlowTest extends InlineExpectationsTest {
  HasFlowTest() { this = "HasFlowTest" }

  override string getARelevantTag() { result = ["hasValueFlow", "hasTaintFlow"] }

  override predicate hasActualResult(Location location, string element, string tag, string value) {
    tag = "hasValueFlow" and
    exists(DataFlow::Node src, DataFlow::Node sink, ValueFlowConf conf | conf.hasFlow(src, sink) |
      sink.getLocation() = location and
      element = sink.toString() and
      value = ""
    )
    or
    tag = "hasTaintFlow" and
    exists(DataFlow::Node src, DataFlow::Node sink, TaintFlowConf conf |
      conf.hasFlow(src, sink) and not any(ValueFlowConf c).hasFlow(src, sink)
    |
      sink.getLocation() = location and
      element = sink.toString() and
      value = ""
    )
  }
}

from ValueFlowConf conf, DataFlow::PartialPathNode source, DataFlow::PartialPathNode sink
where not edges(sink, _) and conf.hasPartialFlow(source, sink, _) and source.getNode().hasLocationInfo(_, 36, _, _, _)
  // and conf.isSink(sink.getNode())
select source, source, sink, concat(sink.getNode().getAQlClass(), ", ")