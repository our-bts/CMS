﻿angular.module('article-list',['resource.articles',"ChannelServices"])

.config(["$routeProvider", ($routeProvider) ->
  $routeProvider
    .when "/",
      templateUrl: "/app/article/list/article-list.tpl.html"
      controller: 'ArticleListCtrl'
      resolve:
        articles: ['$rootScope','$route','$q','Article','channel',($rootScope,$route,$q,Article,channel)->
          deferred = $q.defer()
          channel.getdefault().then (channel) ->
            Article.queryOnce
              $filter:"""
              IsDeleted eq false 
              and Group/Channel/Url eq '#{channel.Url}' 
              """
              $skip:($route.current.params.p ? 1)*10 - 10
            , (data)->
              deferred.resolve data
          deferred.promise
        ]
    .when "/list/:channel/:group/tag/:tag",
      templateUrl: "/app/article/list/article-list.tpl.html"
      controller: 'ArticleListCtrl'
      resolve:
        articles: ['$route','$q','Article',($route,$q,Article)->
          deferred = $q.defer()
          Article.queryOnce
            $filter:"""
            IsDeleted eq false 
            and Group/Channel/Url eq '#{$route.current.params.channel}' 
            and Tags/any(tag:tag/Name eq '#{$route.current.params.tag}')
            """
            $skip:($route.current.params.p ? 1)*10 - 10
          , (data)->
            deferred.resolve data
          deferred.promise
        ]
    .when "/list/:channel/:group",
      templateUrl: "/app/article/list/article-list.tpl.html"
      controller: 'ArticleListCtrl'
      resolve:
        articles: ['$route','$q','Article',($route,$q,Article)->
          deferred = $q.defer()
          Article.queryOnce
            $filter:"""
            IsDeleted eq false 
            and Group/Channel/Url eq '#{$route.current.params.channel}' 
            and Group/Url eq '#{$route.current.params.group}'
            """
            $skip:($route.current.params.p ? 1)*10 - 10
          , (data)->
            deferred.resolve data
          deferred.promise
        ]
    .when "/list/:channel",
      templateUrl: "/app/article/list/article-list.tpl.html"
      controller: 'ArticleListCtrl'
      resolve:
        articles: ['$route','$q','Article',($route,$q,Article)->
          deferred = $q.defer()
          Article.queryOnce
            $filter:"""
            IsDeleted eq false 
            and Group/Channel/Url eq '#{$route.current.params.channel}'
            """
            $skip:($route.current.params.p ? 1)*10 - 10
          , (data)->
            deferred.resolve data
          deferred.promise
        ]
    .when "/search/:key",
      templateUrl: "/app/article/list/article-list.tpl.html"
      controller: 'ArticleListCtrl'
      resolve:
        articles: ['$route','$q','Article',($route,$q,Article)->
          deferred = $q.defer()
          Article.queryOnce
            $filter:"""
            IsDeleted eq false 
            and indexof(Title, '#{$route.current.params.key}') gt -1
            """
            $skip:($route.current.params.p ? 1)*10 - 10
          , (data)->
            deferred.resolve data
          deferred.promise
        ]
])

.controller('ArticleListCtrl',
["$scope","$rootScope","$window","$routeParams","$location","articles","channel", "context"
($scope,$rootScope,$window,$routeParams,$location,articles,channel,context) ->
  $window.scroll(0,0)

  $scope.isAdmin = context.auth.admin

  $rootScope.title=$routeParams.tag ? $routeParams.group ? $routeParams.channel
  if !$rootScope.title
    if $scope.key
      $rootScope.title="Search Result: '#{$scope.key}'"
    else
      channel.getdefault().then (data)->
        $rootScope.title=data.Name
  normalList = []
  topList = []
  for art in articles.value
    if art.ShowInTop
      topList.push(art)
    else
      normalList.push(art)
  $scope.list = articles
  $scope.topList = topList
  $scope.normalList = normalList
  $scope.currentPage =$routeParams.p ? 1

  $scope.params=$routeParams

  #Turn page
  $scope.setPage = (pageNo) ->
    $location.search({p: pageNo})

  $scope.edit = (item) ->
    $window.location.href="/admin/article('#{item.PostId}')"
])