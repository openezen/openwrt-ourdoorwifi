$(function(){
	//function tableSorterAllPages(){
		var cbiMap = $(".cbi-map");
		if(!cbiMap.is("#cbi-hoststat") && !cbiMap.is("#cbi-appstat") && !cbiMap.hasClass('ignoretablesorter')){
			// **********************************
			//  Description of ALL pager options
			// **********************************
			
			var pages = $(".pager");
			
			var table = $("table.tablesorter, table#tablesorter");
			window.tempTable = table;
			table.each(function(i){
				var self = $(this);
				self.find("thead").next("tr").hide();

				if(self.find('tbody tr').length > 0){
					self.tablesorter({
						theme: 'blue',
						widthFixed: true,
						widgets: ['zebra'],
						header: {
							0: { 
								sorter:false 
							},
							1: { 
								sorter:false 
							},
							2: { 
								sorter:false 
							},
							3: { 
								sorter:false 
							},
							4: { 
								sorter:false 
							},
							5: { 
								sorter:false 
							},
							6: { 
								sorter:false 
							},
							7: { 
								sorter:false 
							},
							8: { 
								sorter:false 
							},
							9: { 
								sorter:false 
							},
							10: { 
								sorter:false 
							}
						}
					});

					self.find("th").each(function(){
						$(this).css("background-image","none");
						$(this).find(".tablesorter-header-inner").css("margin","0 5px");
					});
				}
			});
		}
		
	//}
});
