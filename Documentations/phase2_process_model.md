## 1. Process Scope and Objectives

> **BPMN Diagram:** See the full process flow in  
> [Figure 1 – Mining Equipment Maintenance BPMN Diagram](https://github.com/<TlhohonolofatsoSemelane>/<https://github.com/TlhohonolofatsoSemelane/Mining-Equipment-Maintenance-Scheduler>/screenshots/database_objects/phase2_mining_maintenance_process_bpmn.png)

The modeled process is the **Mining Equipment Maintenance Scheduling & Execution** workflow for the *Mining Equipment Maintenance Scheduler (MEMS)* system.

The scope covers activities from **daily equipment inspections and meter readings** to **maintenance scheduling, work order execution, and performance review**. The main objectives are:

- To ensure that mining equipment receives **timely preventive maintenance**.  
- To respond quickly and consistently to **breakdowns and defects**.  
- To maintain a **complete and accurate maintenance history** in the Oracle database.  
- To provide reliable data for **management reports and BI analytics** (availability, downtime, MTBF, costs).

---

## 2. Actors and Roles (Swimlanes)

The BPMN-style diagram in [Figure 1](ttps://github.com/<TlhohonolofatsoSemelane>/<https://github.com/TlhohonolofatsoSemelane/Mining-Equipment-Maintenance-Scheduler>/screenshots/database_objects/phase2_mining_maintenance_process_bpmn.png) uses six main swimlanes:

- **Equipment Operator** – Performs daily inspections, reports defects, and enters meter readings.  
- **System (MEMS)** – Stores data, evaluates maintenance schedules, generates preventive maintenance requests, and updates KPIs.  
- **Maintenance Planner** – Reviews failure reports and system alerts, prioritizes work, creates and schedules work orders, and assigns technicians.  
- **Stores / Warehouse** – Checks and reserves spare parts required to execute work orders.  
- **Maintenance Technician** – Executes maintenance or repair tasks, records time, downtime, and parts used, and updates work order status.  
- **Maintenance Manager** – Reviews maintenance performance indicators and adjusts strategy and policies.

These actors together represent the **core MIS environment** of the maintenance department.

---

## 3. Logical Flow of the Process

The process starts with the **Equipment Operator** performing a **daily inspection** of a machine.

- If a defect is found, the operator creates a **Failure/Defect Report** that is sent to the **Maintenance Planner**.  
- If no issue is found, the operator logs the inspection as OK.

The operator also enters the **meter reading** (hours, kilometers, or tons). The **System (MEMS)** stores this reading and periodically evaluates **maintenance schedules** based on time and usage.

When the system detects that **preventive maintenance is due or overdue**, it automatically generates a **maintenance request** and sends it to the **Maintenance Planner**.

The **Maintenance Planner** reviews:

- Operator failure reports (**corrective maintenance**).  
- System-generated maintenance requests (**preventive maintenance**).

The planner prioritizes work, creates **work orders** (with type, equipment, priority, and planned date), and assigns them to a technician. If spare parts are needed, the planner sends a request to **Stores**.

The **Stores / Warehouse** checks the availability of requested parts:

- If parts are available, they are **reserved** for the work order.  
- If not, the planner is notified, and the work order may be **rescheduled** or put **on hold**.

The **Maintenance Technician** receives the assigned work order. If equipment is available and parts are reserved, the technician:

- Performs the **maintenance or repair**.  
- Uses the reserved parts and records **actual start/end times**, **downtime**, and **comments**.  
- Updates the work order status from **OPEN/IN_PROGRESS** to **COMPLETED**.

If parts or equipment are not available, the technician sets the work order to **ON_HOLD** with a reason, and it returns to the planner for rescheduling.

After completion, the **System (MEMS)** updates:

- **Equipment maintenance history** (what was done, when, by whom).  
- **Equipment status** (*ACTIVE* or *IN_MAINTENANCE*).  
- **Key performance indicators** such as downtime, MTBF, MTTR, and maintenance cost.

Finally, the **Maintenance Manager** reviews periodic reports and KPIs (overdue work orders, number of breakdowns, downtime per equipment, costs) and may adjust **maintenance strategy** (intervals, priorities, or resource allocation). This closes the process cycle.

---

## 4. MIS Functions and Organizational Impact

The process is strongly **MIS-oriented**:

- It supports **operational decisions** (which work orders to execute today, which equipment is available).  
- It feeds **tactical and strategic decisions** (which equipment is unreliable, when to replace assets, how to optimize intervals).  
- All key events—inspections, meter readings, work orders, parts usage—are stored in the **Oracle database**, which later supports **BI dashboards** and analytical queries.

Organizationally, the system improves:

- **Asset reliability** and **equipment availability**.  
- **Planning and control** of maintenance resources and spare parts.  
- **Transparency and accountability**, because every action is logged and visible.  
- **Safety**, since critical defects are formally reported and tracked until resolved.
