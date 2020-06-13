namespace ContentReactor.Common.Fakes
{
    using System;
    using Microsoft.Extensions.Logging;

    /// <summary>
    /// Class created to fake the ILogger.
    /// </summary>
    public abstract class AbstractLogger : ILogger
    {
        /// <summary>
        /// Not used.
        /// </summary>
        /// <param name="state">Not sure.</param>
        /// <typeparam name="TState">Don't know.</typeparam>
        /// <returns>Unh uhn.</returns>
        public IDisposable BeginScope<TState>(TState state)
            => throw new NotImplementedException();

        /// <summary>
        /// OK. Not sure why.
        /// </summary>
        /// <param name="logLevel">The level to log.</param>
        /// <returns>Boolean whether the log level is active.</returns>
        public bool IsEnabled(LogLevel logLevel) => true;

        /// <summary>
        /// Mock log method.
        /// </summary>
        /// <param name="logLevel">The logging level.</param>
        /// <param name="eventId">The id of the event.</param>
        /// <param name="state">The state to go with the log entry.</param>
        /// <param name="exception">The exception to log.</param>
        /// <param name="formatter">String formatter.</param>
        /// <typeparam name="TState">State to log with the event.</typeparam>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1062", Justification="Reviewed")]
        public void Log<TState>(LogLevel logLevel, EventId eventId, TState state, Exception exception, Func<TState, Exception, string> formatter)
            => this.Log(logLevel, exception, formatter(state, exception));

        /// <summary>
        /// Mock log method used by the Log exceptions.
        /// </summary>
        /// <param name="logLevel">The logging level.</param>
        /// <param name="ex">The exception to log.</param>
        /// <param name="information">The information provided with the exception.</param>
        public abstract void Log(LogLevel logLevel, Exception ex, string information);
    }
}
