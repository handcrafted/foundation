# For some reason YAML does not know how to load a serialized array of profiles properly
# unless ruby knows about the class before. Hence this initializer forces Profile to be loaded
# everytime, specifically for Delayed::Jobs
Profile