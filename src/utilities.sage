def parse_kwargs(kwargs, option, default):
    """

    INPUT:

        - ``kwargs`` --  A Dict. Keyword arguments.
        - ``option`` --  Any HashableType. Option key.
        - ``default`` -- Default value.

    OUTPUT:
        
        Returns the provided value if there was one, and the default value otherwise.
    """

    return kwargs[option] if kwargs.has_key(option) else default
