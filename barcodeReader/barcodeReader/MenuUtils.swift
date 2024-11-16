// Main Menu Tab
enum MenuTabView {
    case dashboard
    case calendar
    case inbox
    case properties
}

// Each NavigationStack
enum DashboardNavDestination {
    case calendar
    case inbox
}

enum CalendarNavDestination {
    case specificDate
    case properties
}

enum InboxNavDestination {
    case properties
    case chat
}

enum PropertyNavDestination {
    case propertyDetails
}
