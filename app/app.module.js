(function() {
	angular.module('', ['ui.router']).config(StateProvider);

	function StateProvider($stateProvider, $urlRouterProvider) {
		$urlRouterProvider.otherwise('/');
		$stateProvider
			.state('main', {
				abstract: true,
				templateUrl: 'layout/layout.html',
				controller: 'LayoutCtrl as vm'
			});
	}
})();