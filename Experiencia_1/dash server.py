import dash
from dash.dependencies import Output, Input
import dash_core_components as dcc
import dash_html_components as html
import plotly.graph_objs as go
from QuadrupleTank import DATA

app = dash.Dash(__name__)
app.layout = html.Div(
    [
        dcc.Graph(id = 'live-graph',
                  animate = True),
        dcc.Interval(
            id = 'graph-update',
            interval = 1000,
            n_intervals = 0
        ),
    ]
)
@app.callback(
    Output('live-graph', 'figure'),
    [ Input('graph-update', 'n_intervals') ]
)
def update_graph_scatter(n):
    global DATA, Hmax
    fig = go.Figure()

    # Add traces
    for name in DATA.columns.values:
        fig.add_trace(go.Scatter(x=DATA.index, y=DATA[name],
                             mode='lines+markers',
                             name='lines+markers'))

    return {'data': [fig],
            'layout': go.Layout(xaxis=dict(range=[min(DATA.index), max(DATA.index)]), yaxis=dict(range=[min(0), max(Hmax)]), )}


if __name__ == '__main__':
    app.run_server()