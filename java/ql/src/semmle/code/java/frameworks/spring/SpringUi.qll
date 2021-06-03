import java
import semmle.code.java.dataflow.ExternalFlow

module SpringUi {
  private class FlowSummaries extends SummaryModelCsv {
    override predicate row(string row) {
      row =
        [
          "org.springframework.ui;Model;true;addAttribute;(String,Object);;Argument[0];MapKey of Argument[-1];value",
          "org.springframework.ui;Model;true;addAttribute;(String,Object);;Argument[1];MapValue of Argument[-1];value",
          "org.springframework.ui;Model;true;addAttribute;(Object);;Argument[0];MapValue of Argument[-1];value",
          "org.springframework.ui;Model;true;addAllAttributes;(Collection);;Element of Argument[0];MapValue of Argument[-1];value",
          "org.springframework.ui;Model;true;addAllAttributes;(Map);;MapKey of Argument[0];MapKey of Argument[-1];value",
          "org.springframework.ui;Model;true;addAllAttributes;(Map);;MapValue of Argument[0];MapValue of Argument[-1];value",
          "org.springframework.ui;Model;true;mergeAttributes;(Map);;MapKey of Argument[0];MapKey of Argument[-1];value",
          "org.springframework.ui;Model;true;mergeAttributes;(Map);;MapValue of Argument[0];MapValue of Argument[-1];value",
          "org.springframework.ui;Model;true;getAttribute;;;MapValue of Argument[-1];ReturnValue;value",
          "org.springframework.ui;Model;true;mergeAttributes;;;MapValue of Argument[-1];ReturnValue;value",
          "org.springframework.ui;Model;true;asMap;;;MapKey of Argument[-1];MapKey of ReturnValue;value",
          "org.springframework.ui;Model;true;asMap;;;MapValue of Argument[-1];MapValue of ReturnValue;value",
          "org.springframework.ui;ModelMap;false;ModelMap;(Object);;Argument[0];MapValue of Argument[-1];value",
          "org.springframework.ui;ModelMap;false;ModelMap;(String,Object);;Argument[0];MapKey of Argument[-1];value",
          "org.springframework.ui;ModelMap;false;ModelMap;(String,Object);;Argument[1];MapValue of Argument[-1];value",
          "org.springframework.ui;ModelMap;false;addAllAttributes;(Collection);;Element of Argument[0];MapValue of Argument[-1];value",
          "org.springframework.ui;ModelMap;false;addAttribute;(String,Object);;Argument[0];MapKey of Argument[-1];value",
          "org.springframework.ui;ModelMap;false;addAttribute;(String,Object);;Argument[1];MapValue of Argument[-1];value",
          "org.springframework.ui;ModelMap;false;addAttribute;(Object);;Argument[0];MapValue of Argument[-1];value",
          "org.springframework.ui;ModelMap;false;getAttribute;;;MapValue of Argument[-1];ReturnValue;value",
          "org.springframework.ui;ModelMap;false;mergeAttributes;;;MapValue of Argument[-1];ReturnValue;value",
          "org.springframework.ui;ConcurrentModel;false;put;;;Argument[0];MapKey of Argument[-1];value",
          "org.springframework.ui;ConcurrentModel;false;put;;;Argument[1];MapValue of Argument[-1];value",
          "org.springframework.ui;ConcurrentModel;false;putAll;;;MapValue of Argument[0];MapValue of Argument[-1];value",
          "org.springframework.ui;ConcurrentModel;false;putAll;;;MapKey of Argument[0];MapKey of Argument[-1];value"
        ]
    }
  }
}
