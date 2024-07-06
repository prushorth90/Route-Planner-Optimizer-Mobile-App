
from flask import Flask, request, jsonify
import requests
import json
from ortools.constraint_solver import routing_enums_pb2
from ortools.constraint_solver import pywrapcp
from datetime import datetime
import random
import bs4
import lxml
from bs4 import BeautifulSoup


app = Flask(__name__)

@app.route("/")
def index():
    """Return a friendly HTTP greeting.

    Returns:
        A string with the words 'Hello World!'.
    """
    return "C World!"

@app.route('/searchAddressOfPlace/', methods=['GET'])
def searchAddressOfPlace():
    placeToSearch = request.args.get('placeToSearch')
    apiResponse = requests.get(f'https://maps.googleapis.com/maps/api/place/textsearch/json?query={placeToSearch}&key=AIzaSyDbq-ALkqgJHFvNBDQc-1MJjCk6schskEw')
    return apiResponse.json()

@app.route('/calculateRoute/', methods=['GET', 'POST'])
def calculateRoute():
    """Solve the VRP with time windows."""
    print(request.get_json()['addressOfPlacesToVisit'])
    # Instantiate the data problem.
    data = create_data_model(request.get_json()['addressOfPlacesToVisit'])

    # Create the routing index manager.
    manager = pywrapcp.RoutingIndexManager(
        len(data["time_matrix"]), data["num_vehicles"], data["depot"]
    )

    # Create Routing Model.
    routing = pywrapcp.RoutingModel(manager)

    # Create and register a transit callback.
    def time_callback(from_index, to_index):
        """Returns the travel time between the two nodes."""
        # Convert from routing variable Index to time matrix NodeIndex.
        from_node = manager.IndexToNode(from_index)
        to_node = manager.IndexToNode(to_index)
        return data["time_matrix"][from_node][to_node]

    transit_callback_index = routing.RegisterTransitCallback(time_callback)

    # Define cost of each arc.
    routing.SetArcCostEvaluatorOfAllVehicles(transit_callback_index)

    # Add Time Windows constraint.
    time = "Time"
    routing.AddDimension(
        transit_callback_index,
        30,  # allow waiting time
        30,  # maximum time per vehicle
        False,  # Don't force start cumul to zero.
        time,
    )
    time_dimension = routing.GetDimensionOrDie(time)
    # Add time window constraints for each location except depot.
    for location_idx, time_window in enumerate(data["time_windows"]):
        if location_idx == data["depot"]:
            continue
        index = manager.NodeToIndex(location_idx)
        time_dimension.CumulVar(index).SetRange(time_window[0], time_window[1])
    # Add time window constraints for each vehicle start node.
    depot_idx = data["depot"]
    for vehicle_id in range(data["num_vehicles"]):
        index = routing.Start(vehicle_id)
        time_dimension.CumulVar(index).SetRange(
            data["time_windows"][depot_idx][0], data["time_windows"][depot_idx][1]
        )

    # Instantiate route start and end times to produce feasible times.
    for i in range(data["num_vehicles"]):
        routing.AddVariableMinimizedByFinalizer(
            time_dimension.CumulVar(routing.Start(i))
        )
        routing.AddVariableMinimizedByFinalizer(time_dimension.CumulVar(routing.End(i)))

    # Setting first solution heuristic.
    search_parameters = pywrapcp.DefaultRoutingSearchParameters()
    search_parameters.first_solution_strategy = (
        routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC
    )

    # Solve the problem.
    solution = routing.SolveWithParameters(search_parameters)
    total_time = 0
    # Print solution on console.
    if solution:
        total_time = print_solution(data, manager, routing, solution)
    # FromHotelToVisitAllLocations
    # Create a dictionary
    data = {
        "name": "Test",
        "age": 30,
        "city": "Los Angeles",
        "totalTime" : total_time
    }

    # Convert the dictionary to a
    # JSON string with double quotes
    json_string = json.dumps(data, ensure_ascii=False)

    return json_string


def create_data_model(listOfAddressesOfPlacesToVisit):
    """Stores the data for the problem."""
    data = {}
    data["time_matrix"] = buildTimeMatrix(listOfAddressesOfPlacesToVisit)
    data["time_windows"] = buildTimeWindowMatrix(listOfAddressesOfPlacesToVisit)
    data["num_vehicles"] = 1
    data["depot"] = 0
    return data

def buildTimeMatrix(listOfAddressesOfPlacesToVisit):
    addressesSeperatedByPipeline = createBigStringSeperatedByPipeline(listOfAddressesOfPlacesToVisit)

    apiResponse = requests.get(f'https://maps.googleapis.com/maps/api/distancematrix/json?destinations={addressesSeperatedByPipeline}&origins={addressesSeperatedByPipeline}&units=imperial&key=AIzaSyDbq-ALkqgJHFvNBDQc-1MJjCk6schskEw')
    
    data = apiResponse.json()
    distance_matrix = []

    for row in data['rows']:
        row_distances = []
        for element in row['elements']:
            # Convert distance from feet to miles if necessary
            distance_text = element['distance']['text']
            if 'ft' in distance_text:
                distance_value = 0.0  # Assuming 1 ft is negligible in miles
            else:
                distance_value = float(distance_text.split()[0])
            row_distances.append(distance_value)
        distance_matrix.append(row_distances)
    return distance_matrix

def createBigStringSeperatedByPipeline(listOfAddressesOfPlacesToVisit):
    separator = "%7C"
    result = separator.join(listOfAddressesOfPlacesToVisit)
    return result

def buildTimeWindowMatrix(listOfAddressesOfPlacesToVisit):
    listOfOpenAndCloseTimes = []
    for addr in listOfAddressesOfPlacesToVisit:
       #fetch - issue list of strings does not have place id unless fetch again - another issue missign oepn and clsoe times what can i do
       print(addr)
       apiResponse1 = requests.get(f'https://maps.googleapis.com/maps/api/place/textsearch/json?query={addr}&key=AIzaSyDbq-ALkqgJHFvNBDQc-1MJjCk6schskEw')
       
       newPlaceId = apiResponse1.json()['results'][0]['place_id']
       apiResponse = requests.get(f'https://places.googleapis.com/v1/places/{newPlaceId}?fields=currentOpeningHours&key=AIzaSyDbq-ALkqgJHFvNBDQc-1MJjCk6schskEw')
       data = apiResponse.json()

       # Find today's opening and closing times in the periods
       if data != {}:
            for period in data["currentOpeningHours"]["periods"]:
                if period["open"]["day"] == 1:
                    open_hour = period["open"]["hour"]
                    close_hour = period["close"]["hour"]
                    listOfOpenAndCloseTimes.append((open_hour, close_hour))
       else:
             # did not find from google api so scraped instead
             headers = { "User-Agent": "Mozilla/5.0 (X11; System x86_64) AppleWebKit/537.123 (KHTML, like Gecko)  Chrome/100.0.111.111 Safari/537.123" }
             params = {
                "q": f'{addr} hours',
                "hl": "en",
             }
             response = requests.get(
                "https://www.google.com/search", headers=headers, params=params
             )
             soup = BeautifulSoup(response.text, "lxml")
             hours_wrapper_node = soup.select_one("[data-attrid='kc:/location/location:hours']")
             if hours_wrapper_node is None:
                listOfOpenAndCloseTimes.append((0,24))
                continue
             business_hours = {"open_closed_state": "", "hours": []}
             business_hours["open_closed_state"] = hours_wrapper_node.select_one(".JjSWRd span span span").text.strip()
             location_hours_rows_nodes = hours_wrapper_node.select("table tr")
             for location_hours_rows_node in location_hours_rows_nodes:
                [day_of_week, hours] = [td.text.strip() for td in location_hours_rows_node.select("td")]
                business_hours["hours"].append({"day_of_week": day_of_week, "business_hours": hours})
             
             listOfOpenAndCloseTimes.append(getOpenHourAndClosedHour(business_hours))
             #print( business_hours)
    
    print(listOfOpenAndCloseTimes)
    print("ALLEZ ALLEZ ALLEZ ALLEZ ALLEZ ALLEZ ALLEZ ALLEZ ALLEZ ALLEZ")
    return listOfOpenAndCloseTimes

def getOpenHourAndClosedHour(data):
    for entry in data['hours']:
        if entry['day_of_week'] == 'Friday':
            hours = entry['business_hours']
            if hours != 'Closed':
                # Removing non-breaking space and extracting hours
                hours = hours.replace('\u202f', '')
                start, end = hours.split('–')
                start_hour = convert_time_to_24_hour_format(start)
                end_hour = convert_time_to_24_hour_format(end)
                return (start_hour, end_hour)
            else:
                return (0,24)
    
    return (0,24)

def convert_time_to_24_hour_format(time_str):
    hour, period = time_str[:-2], time_str[-2:]
    hour = int(hour.split(':')[0])
    if period == 'PM' and hour != 12:
        hour += 12
    elif period == 'AM' and hour == 12:
        hour = 0
    return hour
    
def print_solution(data, manager, routing, solution):
    """Prints solution on console."""
    print(f"Objective: {solution.ObjectiveValue()}")
    time_dimension = routing.GetDimensionOrDie("Time")
    total_time = 0
    for vehicle_id in range(data["num_vehicles"]):
        index = routing.Start(vehicle_id)
        plan_output = f"Route for vehicle {vehicle_id}:\n"
        while not routing.IsEnd(index):
            time_var = time_dimension.CumulVar(index)
            plan_output += (
                f"{manager.IndexToNode(index)}"
                f" Time({solution.Min(time_var)},{solution.Max(time_var)})"
                " -> "
            )
            index = solution.Value(routing.NextVar(index))
        time_var = time_dimension.CumulVar(index)
        plan_output += (
            f"{manager.IndexToNode(index)}"
            f" Time({solution.Min(time_var)},{solution.Max(time_var)})\n"
        )
        plan_output += f"Time of the route: {solution.Min(time_var)}min\n"
        print(plan_output)
        total_time += solution.Min(time_var)
    print(f"Total time of all routes: {total_time}min")
    return total_time
    
if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=True)

