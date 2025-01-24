
model official

global {
	

	shape_file road_file <- shape_file("../external/try road.shp"); //fixed not whole mayondon


	//shape_file road_file <- shape_file("../external/road.shp"); //not fixed not whole mayondon

	shape_file building_file <- shape_file("../external/buildings.shp"); //fixed not whole mayondon


	//shape_file road_file <- shape_file("../external/road dissovled.shp"); // fixed whole mayondon

	//file building_file <- file("../../Basic Tests/external/building.shp"); // fixed whole mayondon

	//file road_file <- file	("../external/copy of feline road.shp"); //not fixed but whole mayondon

	//shape_file road_file <- shape_file("../../Tutorials/Incremental Model/includes/road.shp"); //default map

	//shape_file building_file <- shape_file("../../Tutorials/Incremental Model/includes/building.shp"); //default map

	geometry shape <- envelope(road_file);
	graph road_network;
	
	int nb_cats_male <- 30;
	int nb_cats_female <- 30;
	float agent_speed <- 0.5 #km / #h;
	float proba_breed <- 0.005;
	float step <- 1440 #mn;
	int number_of_food_source <- 10;
	int when_hungry_get_food <- 200;
	int die_when_hungry <- 500;
	int max_offspring <- 19; //number of kittens can be reproduced by female cats
	float accidental_death_proba <- 0.00005;

	
	
	


	init {
		create road from: road_file;
		create building from: building_file;
		road_network <- as_edge_graph(road);
		
		
		create food_source number: number_of_food_source{
			location <- one_of(road_network);
		}
		
		create cats_male number: nb_cats_male {
			speed <- agent_speed;
			road rd <- one_of(road_network);
			location <- any_location_in(rd);


		}
		create cats_female number: nb_cats_female{
			speed <- agent_speed;
			road rd <- one_of(road_network);
			location <- any_location_in(rd);

			
			}
			
		
	}
	
	
}


species food_source{
	rgb color <- #red;
	
}

species cats_female skills: [moving]{
	int hunger;
	int age;
	string age_category;rgb color <- #pink;
	point target <- nil;
	int total_offspring <- rnd(70, 120);
	int max_offspring <- rnd(3, 6);
	int current_offspring;
	int nb_offsprings;

	
	//365 = 1 year
	
	reflex age {
		age <- age + 1;
		
		if (age = 1){
			age_category <- "kitten";
		}
		if (age = 1095){//3years
			age_category <- "adult";
		}
		if (age = 3650){
			age_category <- "senior";
		}
	}
	
	reflex increase_hunger {
        hunger <- hunger + 1; // Increment hunger by 1
    }
   
    reflex when_hungry when: hunger >= when_hungry_get_food {
    	target <- point(one_of(food_source));
    	if location = target{
    		hunger <- 0;
    	}
    }
    
    reflex not_hungry when: hunger <= when_hungry_get_food {
    	target <- any_location_in(one_of(building));
    }
    
    reflex dies_of_hunger when: hunger = die_when_hungry{
    	write "female cat: dies of hunger";
    	do die;
    }
    
    reflex old when: age = 5110{
    	write "female cat: dies of old age" ;
		do die;
	}
	reflex accidental_death when: flip(accidental_death_proba) {
		write "female cat: dies of accident";
		do die;
	}
    
    reflex move when: target != nil {
		do goto target: target on: road_network ; 
			if target = location {
	    	target <- nil ;
		}
	}
	
	aspect sphere {
		draw sphere(5) color:  #purple;
}

	

bool cannot_breed_anymore <- false;
	action breed {
		if age_category = "adult" {
			nb_offsprings <- rnd(1, max_offspring);
			int nb_female_offsprings <- rnd(0, nb_offsprings);
    		int nb_male_offsprings <- nb_offsprings - nb_female_offsprings;
			create species(cats_female) number: nb_female_offsprings  {
				age <- 1;
				hunger <- 0;
				age_category <- "kitten";
				speed <- agent_speed;
				location <- myself;
				}
			create species(cats_male) number: nb_male_offsprings {
        		age <- 1;
        		hunger <- 0;
        		age_category <- "kitten";
        		speed <- agent_speed;
				location <- myself;
		}
		
	}
		
		
	}
	
}



species cats_male skills: [moving] {
	int hunger <- 0;
	int age;
	string age_category;
	rgb color <- #blue;
	point target <- nil;
	

	//365 = 1 year
	reflex age {
		age <- age + 1;
		if (age = 1){
			age_category <- "kitten";
		}
		if (age = 365){
			age_category <- "adult";
		}
		if (age = 3650){
			age_category <- "senior";
		}
	}
	

	// Actions that might increase hunger
	reflex increase_hunger {
        hunger <- hunger + 1; // Increment hunger by 1
    }
   
    reflex when_hungry when: hunger >= when_hungry_get_food {
    	target <- point(one_of(food_source));
    	if location = target{
    		hunger <- 0;
    	}
    }
    
    reflex not_hungry when: hunger <= when_hungry_get_food {
    	target <- any_location_in(one_of(building));
    }
    
    reflex dies_of_hunger when: hunger = die_when_hungry{
    	write "male cat: dies of hunger";
    	do die;
    }
    	reflex old when: age = 5110{
    	write "male cat: dies of old age";
		do die;
	}
	reflex accidental_death when: flip(accidental_death_proba) {
		write "male cat: dies of accident";
		do die;
	}
    
	reflex move when: target != nil {
		do goto target: target on: road_network ; 
			if target = location {
	    	target <- nil ;
		}
	}
	aspect sphere {
		draw sphere(5)color:  #blue;
	}
	
	reflex breed when: age_category = "adult"{
		ask cats_female at_distance 0 {
			if flip(proba_breed) and cannot_breed_anymore = false{
				do breed;
				current_offspring <- current_offspring + nb_offsprings;
				if current_offspring >= total_offspring {
					cannot_breed_anymore <- true;
				}
				
			}
		}
	}
	
	
	}

species road {
	geometry display_shape <- shape + 2.0;

	aspect base {
		draw shape color: #black depth: 3.0;
	}
}

species building {
	string type;
	rgb color <- #gray;
}

experiment main_experiment type: gui {
	parameter "initial number of male cats" var: nb_cats_male min: 0 max: 200;
	parameter "initial number of female cats" var: nb_cats_female min: 0 max: 200;
	parameter "breeding probability" var: proba_breed min: 0.0 max: 0.5;
	parameter "number of food source" var: number_of_food_source min: 0 max: 20;
	parameter "get food when hungry" var: when_hungry_get_food min: 0 max: 500;
	parameter "die when hungry" var: die_when_hungry min: 0 max: 2000;
	parameter "agent speed" var: agent_speed min: 0.0 max: 1.0;
	parameter "accidental deaths" var: accidental_death_proba min: 0.000001 max: 0.0005 ;


	
	output {
		

		display map_2D type: 2d {
			
		
				species road aspect: base;
				species cats_male aspect: sphere;
				species cats_female aspect: sphere;
				species food_source;
				species building transparency: 0.8;
				
				}
				display another_chart type: 2d refresh: every(10 #cycles){
					chart "agent count" type: series{
						data "kitten" value: cats_male count (each.age_category="kitten")  color: #magenta ;
						data "adult" value: cats_male count (each.age_category="adult") color: #blue ;
						data "senior" value: cats_male count (each.age_category="senior") color: #red;
					}
				}
				display total_cats type: 2d refresh: every(10 #cycles){
					chart "total cats" type: series{
						data "total cats" value: 
						cats_male count (each.age_category = "kitten")+ 
						cats_male count(each.age_category = "adult") + 
						cats_male count(each.age_category = "senior") +
						cats_female count(each.age_category = "kitten")+
						cats_female count(each.age_category = "adult")+
						cats_female count(each.age_category = "senior");
						
					}
				}
				display chart2 refresh: every(10#cycles) type:2d{
						chart "gender counts" type: series {
							data "male cats" value: 
							cats_male count (each.age_category = "kitten")+ 
							cats_male count(each.age_category = "adult") + 
							cats_male count(each.age_category = "senior");
							data "female cats" value:
							cats_female count(each.age_category = "kitten")+
							cats_female count(each.age_category = "adult")+
							cats_female count(each.age_category = "senior");
							
							
						}
					}
				display pie1 refresh: every(10#cycles)  type: 2d {
					chart "total cat age category" type: pie style: exploded size: {1, 0.5} position: {0, 0.5}{
						data "kitten" value: cats_male count (each.age_category="kitten") + cats_female count(each.age_category = "kitten") color: #magenta ;
						data "adult" value: cats_male count (each.age_category="adult") + cats_female count(each.age_category = "adult")color: #blue ;
						data "senior" value: cats_male count (each.age_category="senior") + cats_female count(each.age_category = "senior")color: #red;
					}
					}
					display pie2 refresh: every(10#cycles)  type: 2d {
					chart "male age category" type: pie style: exploded size: {1, 0.5} position: {0, 0.5}{
						data "kitten" value: cats_male count (each.age_category = "kitten");
						data "adult" value: cats_male count (each.age_category = "adult");
						data "senior" value: cats_male count (each.age_category = "senior");
					}
					
					}
					display pie3 refresh: every(10#cycles)  type: 2d {
					chart "female age category" type: pie style: exploded size: {1, 0.5} position: {0, 0.5} {
						data "kitten" value: cats_female count (each.age_category = "kitten");
						data "adult" value: cats_female count (each.age_category = "adult");
						data "senior" value: cats_female count (each.age_category = "senior");
					}
					
					}
					
		


				}
				
				
				}
			
		
		
		
	
	
