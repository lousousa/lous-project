stateProvider = ($stateProvider, $urlRouterProvider)->
	$urlRouterProvider.otherwise("/")
	$stateProvider
		.state("main", {
			abstract: true
			templateUrl: "layout/layout.html"
			controller: "LayoutCtrl as vm"
		})
	return

angular
	.module("", [
		"ui.router"
])
	.config(stateProvider)