/**
 * Provides models for the `org.springframework.data` package.
 */

import java
private import semmle.code.java.dataflow.ExternalFlow

private class FlowSummaries extends SummaryModelCsv {
  override predicate row(string row) {
    row =
      [
        // data.repository
        "org.springframework.data.repository;CrudRepository;true;findAll;;;MapValue of Argument[-1];Element of ReturnValue;value",
        "org.springframework.data.repository;CrudRepository;true;findAllById;;;MapValue of Argument[-1];Element of ReturnValue;value",
        "org.springframework.data.repository;CrudRepository;true;findById;;;MapValue of Argument[-1];Element of ReturnValue;value",
        "org.springframework.data.repository;CrudRepository;true;save;;;Argument[0];MapValue of Argument[-1];value",
        "org.springframework.data.repository;CrudRepository;true;saveAll;;;Argument[0];MapValue of Argument[-1];value",
        "org.springframework.data.repository;PagingAndSortingRepository;true;findAll;;;MapValue of Argument[-1];Element of ReturnValue;value"

        "org.springframework.data.config;ConfigurationUtils;true;"

        "org.springframework.data.domain;Slice;true;map;;;Element of Argument[-1];MapKey of ReturnValue;value",
        "org.springframework.data.domain;Slice;true;getContent;;;Element of Argument[-1];Element of ReturnValue;value",

        // org.springframework.data.web
        // HateoasPageableHandlerMethodArgumentResolver only contains and transmits page number / page size
        // HateoasSortHandlerMethodArgumentResolver only contains and transmits sorts (specified by data.domain.Sort)
        // JsonProjectingMethodInterceptorFactory creates a method interceptor that decodes json, as far as I can tell; taint could be propagated from json / mapping providers
        //   to the generated method interceptors, but handling method interceptors in general seems quite difficult. Perhaps a synthetic field `.MethodInterceptor` to the `Advised` class that is propagated via all methods?
        // TODO: model Spring hateoas DTOs (PagedResources)
        "org.springframework.data.web;PagedResourcesAssembler;toModel;;;Element of Argument[0];Element of ReturnValue;value"
        // SortHandlerMethodArgumentResolverSupport deals with the `Sort` type which probably doesn't contain very much taint


        // org.springframework.data.web.querydsl only contains implementations of interfaces
      ]
    }
  }
}
